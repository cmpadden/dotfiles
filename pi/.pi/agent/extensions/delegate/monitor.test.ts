import assert from "node:assert/strict";
import { execFile, spawn } from "node:child_process";
import { once } from "node:events";
import { readFile, stat, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";
import { openMonitor } from "./monitor.ts";
import { initialDetails } from "./runtime.ts";
import { renderMonitor, safeText } from "./monitor-view.mjs";

const details = () => initialDetails({ task: "Inspect", provider: "test", model: "model", cwd: tmpdir(), trusted: false });
const exec = promisify(execFile);

test("monitor targets the parent without focus, bounds private snapshots, and cleans up idempotently", async () => {
  const calls: string[][] = [];
  const monitor = await openMonitor("Inspect 'quotes'; $(false)", details(), "%123", async (args) => {
    calls.push(args);
    return "%456";
  });
  const args = calls[0];
  assert.deepEqual(args.slice(0, 9), ["split-window", "-d", "-h", "-t", "%123", "-P", "-F", "#{pane_id}", process.execPath]);
  const path = args.at(-2)!;
  try {
    assert.equal((await stat(path)).mode & 0o777, 0o600);
    assert.equal((await stat(dirname(path))).mode & 0o777, 0o700);
    monitor.update({ ...details(), status: "running", output: "x".repeat(100000) });
    const state = JSON.parse(await readFile(path, "utf8"));
    assert.equal(state.output.length, 16384);
    assert.equal(state.label, "Inspect 'quotes'; $(false)");
  } finally { await monitor.close(); }
  await monitor.close();
  monitor.update(details());
  assert.deepEqual(calls[1], ["kill-pane", "-t", "%456"]);
  assert.equal(calls.length, 2);
  await assert.rejects(stat(dirname(path)), { code: "ENOENT" });
});

test("missing/invalid pane and split failures fall back without leaking snapshot files", async () => {
  for (const target of ["", "not-a-pane"]) {
    await assert.rejects(openMonitor("Inspect", details(), target, async () => assert.fail("must not call tmux")));
  }
  let path = "";
  await assert.rejects(openMonitor("Inspect", details(), "%1", async (args) => {
    path = args.at(-2)!;
    throw new Error("no space for pane");
  }));
  await assert.rejects(stat(dirname(path)), { code: "ENOENT" });
});

test("closed panes and missing snapshot directories do not break child progress or cleanup", async () => {
  let path = "";
  const monitor = await openMonitor("Inspect", details(), "%1", async (args) => {
    if (args[0] === "kill-pane") throw new Error("pane already closed");
    path = args.at(-2)!;
    return "%2";
  });
  await rm(dirname(path), { recursive: true });
  assert.doesNotThrow(() => monitor.update(details()));
  await monitor.close();
});

test("viewer formats status/activity/output and strips terminal control sequences", () => {
  assert.equal(safeText("a\x1b[31mb\x1b[0m\x07\r\x1b]52;c;secret\x07"), "ab");
  const text = renderMonitor({ ...details(), label: "Inspect", cost: 0.12, activity: ["→ read file"], output: "Found it" });
  assert.match(text, /Delegate · queued · 0s · \$0.1200/);
  assert.match(text, /→ read file/);
  assert.match(text, /Found it/);
});

test("viewer launched through a Stow-style symlink renders and exits when its snapshot disappears", { timeout: 5000 }, async () => {
  const directory = await mkdtemp(join(tmpdir(), "delegate-viewer-test-"));
  const viewer = join(directory, "viewer.mjs");
  const path = join(directory, "state.json");
  await symlink(fileURLToPath(new URL("monitor-view.mjs", import.meta.url)), viewer);
  await writeFile(path, JSON.stringify({ ...details(), label: "SYMLINK_MONITOR", cost: 0 }));
  const proc = spawn(process.execPath, [viewer, path, String(process.pid)], { stdio: ["ignore", "pipe", "pipe"] });
  const exited = once(proc, "close");
  try {
    const output = await Promise.race([
      once(proc.stdout, "data").then(([data]) => String(data)),
      exited.then(([code]) => { throw new Error(`Viewer exited before rendering: ${code}`); }),
    ]);
    assert.match(output, /SYMLINK_MONITOR/);
    await rm(path);
    const [code] = await exited;
    assert.equal(code, 0);
  } finally {
    if (proc.exitCode === null) proc.kill();
    await exited;
    await rm(directory, { recursive: true, force: true });
  }
});

test("real tmux pane stays in the parent's window, renders updates, and closes", { timeout: 10000 }, async (t) => {
  try { await exec("tmux", ["-V"]); } catch { t.skip("tmux unavailable"); return; }
  const directory = await mkdtemp(join(tmpdir(), "delegate-tmux-test-"));
  const socket = join(directory, "socket");
  const command = async (args: string[]) => (await exec("tmux", ["-S", socket, ...args], { timeout: 2000 })).stdout.trim();
  let monitor: Awaited<ReturnType<typeof openMonitor>> | undefined;
  try {
    const parent = await command(["-f", "/dev/null", "new-session", "-d", "-x", "120", "-y", "99", "-P", "-F", "#{pane_id}", "/bin/sleep", "60"]);
    const unrelated = await command(["split-window", "-d", "-v", "-t", parent, "-l", "49", "-P", "-F", "#{pane_id}", "/bin/sleep", "60"]);
    const unrelatedGeometry = await command(["display-message", "-p", "-t", unrelated, "#{pane_left} #{pane_top} #{pane_width} #{pane_height}"]);
    monitor = await openMonitor("Inspect test", details(), parent, command);
    const panes = (await command(["list-panes", "-t", parent, "-F", "#{pane_id}"])).split("\n");
    assert.equal(panes.length, 3);
    const pane = panes.find((id) => id !== parent && id !== unrelated)!;
    assert.equal(await command(["display-message", "-p", "-t", parent, "#{pane_active}"]), "1");
    monitor.update({ ...details(), status: "running", output: "LIVE_MONITOR_OUTPUT" });
    let captured = "";
    for (let i = 0; i < 50; i++) {
      captured = await command(["capture-pane", "-p", "-t", pane]);
      if (captured.includes("LIVE_MONITOR_OUTPUT")) break;
      await new Promise((resolve) => setTimeout(resolve, 50));
    }
    assert.match(captured, /Inspect test/);
    assert.match(captured, /LIVE_MONITOR_OUTPUT/);

    const geometry = async () => (await command([
      "list-panes", "-t", parent, "-F", "#{pane_id} #{pane_left} #{pane_top} #{pane_width} #{pane_height}",
    ])).split("\n").map((line) => {
      const [id, ...values] = line.split(" ");
      const [left, top, width, height] = values.map(Number);
      return { id, left, top, width, height };
    });
    const parentGeometry = (await geometry()).find(({ id }) => id === parent)!;
    assert.equal(parentGeometry.height, 49);
    assert.ok(parentGeometry.width < 120);
    const others = await Promise.all([
      openMonitor("Second", details(), parent, command),
      openMonitor("Third", details(), parent, command),
    ]);
    try {
      const assertColumn = async (count: number) => {
        const panes = await geometry();
        assert.equal(panes.length, count + 2);
        assert.equal(await command(["display-message", "-p", "-t", unrelated, "#{pane_left} #{pane_top} #{pane_width} #{pane_height}"]), unrelatedGeometry);
        assert.deepEqual(panes.find(({ id }) => id === parent), parentGeometry);
        const monitors = panes.filter(({ id }) => id !== parent && id !== unrelated);
        for (const item of monitors) {
          assert.equal(item.left, parentGeometry.width + 1);
          assert.equal(item.width, 120 - parentGeometry.width - 1);
        }
        const heights = monitors.map(({ height }) => height);
        assert.ok(Math.max(...heights) - Math.min(...heights) <= 1, `Unbalanced monitor heights: ${heights}`);
        assert.equal(new Set(monitors.map(({ top }) => top)).size, count);
        assert.equal(await command(["display-message", "-p", "-t", parent, "#{pane_active}"]), "1");
      };
      await assertColumn(3);
      // Finishing the first monitor must not lose the right-hand stack.
      await monitor.close();
      await assertColumn(2);
      const replacement = await openMonitor("Replacement", details(), parent, command);
      try { await assertColumn(3); } finally { await replacement.close(); }
      // Manually closing all remaining viewers makes the next launch start right again.
      for (const item of (await geometry()).filter(({ id }) => id !== parent && id !== unrelated)) {
        await command(["kill-pane", "-t", item.id]);
      }
      const restarted = await openMonitor("Restarted", details(), parent, command);
      try { await assertColumn(1); } finally { await restarted.close(); }
    } finally {
      await Promise.all(others.map((item) => item.close()));
    }
    await monitor.close();
    assert.deepEqual((await command(["list-panes", "-t", parent, "-F", "#{pane_id}"])).split("\n"), [parent, unrelated]);
  } finally {
    await monitor?.close();
    try { await command(["kill-server"]); } catch { /* already stopped */ }
    await rm(directory, { recursive: true, force: true });
  }
});
