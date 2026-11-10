import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { promisify } from "node:util";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import extension from "./index.ts";
import { HEARTBEAT_MS, PaneStatus, type RunTmux } from "./runtime.ts";

const exec = promisify(execFile);
type Context = { mode: string; isIdle: () => boolean };
type Handler = (event: { aborted?: boolean }, ctx: Context) => unknown;

function harness(run: RunTmux = async () => ({ code: 0 }), insideTmux = true) {
  const handlers = new Map<string, Handler>();
  const calls: string[][] = [];
  const previous = { TMUX: process.env.TMUX, TMUX_PANE: process.env.TMUX_PANE };
  try {
    process.env.TMUX = insideTmux ? "/tmp/test-tmux,1,0" : "";
    process.env.TMUX_PANE = insideTmux ? "%0" : "";
    extension({
      on(name: string, handler: Handler) { handlers.set(name, handler); },
      exec(_command: string, args: string[]) { calls.push(args); return run(args); },
    } as unknown as ExtensionAPI);
  } finally {
    for (const key of ["TMUX", "TMUX_PANE"] as const) {
      if (previous[key] === undefined) delete process.env[key];
      else process.env[key] = previous[key];
    }
  }
  return {
    calls,
    handlers,
    async emit(name: string, event = {}, ctx: Context = { mode: "tui", isIdle: () => true }) {
      await handlers.get(name)?.(event, ctx);
    },
  };
}

function lastState(calls: string[][]) {
  return calls.at(-1)?.at(-1)?.match(/@pi_status (\w+)/)?.[1];
}

test("lifecycle distinguishes prompts, retries, completion, and aborts", async (t) => {
  const h = harness();
  t.after(() => h.emit("session_shutdown"));
  assert.equal(h.calls.length, 0, "no subprocesses or timers at factory time");
  await h.emit("session_start");
  assert.equal(lastState(h.calls), "idle");
  await h.emit("before_agent_start");
  assert.equal(lastState(h.calls), "working");
  const count = h.calls.length;
  await h.emit("agent_start");
  assert.equal(h.calls.length, count, "duplicate working state is coalesced");
  await h.emit("ui_prompt_start");
  assert.equal(lastState(h.calls), "waiting");
  await h.emit("ui_prompt_end");
  assert.equal(lastState(h.calls), "working");
  assert.equal(h.handlers.has("agent_end"), false, "low-level completion is not idle");
  await h.emit("agent_settled", { aborted: false });
  assert.equal(lastState(h.calls), "done");
  await h.emit("agent_start");
  await h.emit("agent_settled", { aborted: true });
  assert.equal(lastState(h.calls), "idle", "an aborted run is not advertised as done");
});

test("compaction is busy and returns to the preceding state, including failure", async (t) => {
  const h = harness();
  t.after(() => h.emit("session_shutdown"));
  await h.emit("session_start");
  await h.emit("session_before_compact");
  assert.equal(lastState(h.calls), "working");
  await h.emit("session_compact_failed");
  assert.equal(lastState(h.calls), "idle");
  await h.emit("agent_start");
  await h.emit("agent_settled");
  await h.emit("session_before_compact");
  assert.equal(lastState(h.calls), "working");
  await h.emit("session_compact");
  assert.equal(lastState(h.calls), "done");
});

test("non-tmux and noninteractive invocations never claim a pane", async () => {
  const outside = harness(undefined, false);
  assert.equal(outside.handlers.size, 0);
  for (const mode of ["print", "json", "rpc"]) {
    const h = harness();
    await h.emit("session_start", {}, { mode, isIdle: () => false });
    await h.emit("agent_start");
    await h.emit("agent_settled");
    await h.emit("session_shutdown");
    assert.deepEqual(h.calls, [], mode);
  }
});

test("heartbeat renews state and shutdown stops it", async (t) => {
  t.mock.timers.enable({ apis: ["setInterval"] });
  const h = harness();
  t.after(() => h.emit("session_shutdown"));
  await h.emit("session_start");
  const count = h.calls.length;
  t.mock.timers.tick(HEARTBEAT_MS);
  // Queue another state change to wait until the heartbeat write has drained.
  await h.emit("agent_start");
  assert.equal(h.calls.length, count + 2);
  assert.match(h.calls[count].at(-1)!, /@pi_status idle/);
  await h.emit("session_shutdown");
  const stoppedCount = h.calls.length;
  t.mock.timers.tick(HEARTBEAT_MS * 3);
  await h.emit("agent_start");
  assert.equal(h.calls.length, stoppedCount);
});

test("overlapping UI events are serialized before shutdown cleanup", async () => {
  const h = harness();
  await h.emit("session_start");
  const count = h.calls.length;
  await Promise.all([
    h.emit("agent_start"),
    h.emit("ui_prompt_start"),
    h.emit("ui_prompt_end"),
    h.emit("session_shutdown"),
  ]);
  const commands = h.calls.slice(count).map((args) => args.at(-1)!);
  assert.match(commands[0], /@pi_status working/);
  assert.match(commands[1], /@pi_status waiting/);
  assert.match(commands[2], /@pi_status working/);
  assert.match(commands[3], /set-option -pu/);
});

test("failed tmux commands do not reject lifecycle events", async () => {
  for (const run of [
    async () => { throw new Error("tmux unavailable"); },
    async () => ({ code: 1 }),
  ]) {
    const h = harness(run);
    await h.emit("session_start");
    await h.emit("agent_start");
    await h.emit("session_shutdown");
    await h.emit("session_shutdown");
  }
});

test("tmux renders per-window aggregates, leases, pane moves, and ownership", async (t) => {
  try {
    await exec("tmux", ["-V"]);
  } catch {
    t.skip("tmux is not installed");
    return;
  }
  const directory = await mkdtemp(join(tmpdir(), "pi-tmux-status-"));
  const socket = join(directory, "socket");
  const tmux = async (...args: string[]) => {
    const { stdout, stderr } = await exec("tmux", ["-S", socket, ...args], { timeout: 3_000 });
    assert.equal(stderr, "");
    return stdout.trim();
  };
  const statuses: PaneStatus[] = [];
  t.after(async () => {
    for (const status of statuses) await status.stop();
    try { await tmux("kill-server"); } catch { /* already stopped */ }
    await rm(directory, { recursive: true, force: true });
  });
  const pane1 = await tmux("-f", "/dev/null", "new-session", "-d", "-P", "-F", "#{pane_id}", "-s", "check", "-n", "editor", "/bin/sh");
  const pane2 = await tmux("split-window", "-d", "-P", "-F", "#{pane_id}", "/bin/sh");
  const config = await readFile(new URL("../../../../../tmux/.config/tmux/tmux.conf", import.meta.url), "utf8");
  // Exercise the repository's actual formats, without loading plugins or bindings.
  const formats = config.split("\n").filter((line) => /^set -g (?:@pi_status_|window-status-(?:current-)?format )/.test(line));
  assert.equal(formats.length, 5);
  const configFile = join(directory, "formats.conf");
  await writeFile(configFile, formats.join("\n") + "\n");
  await tmux("source-file", configFile);
  const failures: unknown[] = [];
  const run: RunTmux = async (args) => {
    try {
      await tmux(...args);
      return { code: 0 };
    } catch (error) {
      failures.push(error);
      return { code: 1 };
    }
  };
  const create = (pane: string, owner: string) => {
    const status = new PaneStatus(run, pane, owner);
    statuses.push(status);
    return status;
  };
  const badge = (target: string) => tmux("display-message", "-p", "-t", target, "#{E:@pi_status_badge}");
  const first = create(pane1, "first");
  const second = create(pane2, "second");
  await first.start("idle");
  assert.deepEqual(failures, []);
  assert.equal(await badge(pane1), "[pi:idle]", await tmux("display-message", "-p", "-t", pane1, "#{@pi_status} / #{@pi_status_until} / #{T:@pi_status_time}"));
  await first.update("working");
  await second.start("done");
  assert.equal(await badge(pane1), "[pi:working]");
  assert.equal(await badge(pane2), "[pi:working]", "inactive panes contribute too");
  await second.update("waiting");
  assert.equal(await badge(pane1), "[pi:waiting]");
  await second.stop();
  assert.equal(await badge(pane1), "[pi:working]", "one pane exiting cannot clear another");
  await first.update("done");
  assert.equal(await badge(pane1), "[pi:done]");
  for (const option of ["window-status-format", "window-status-current-format"]) {
    const format = await tmux("show-options", "-gv", option);
    const rendered = await tmux("display-message", "-p", "-t", pane1, format);
    assert.match(rendered, /0 editor\s+\[pi:done\]/, "Pi status follows the window name inline");
  }
  const windowList = "#{W:#{E:window-status-format},#{E:window-status-current-format}}";
  assert.equal(await tmux("display-message", "-p", "-t", pane1, "#{window_name}"), "editor");
  await tmux("set-option", "-p", "-t", pane1, "@pi_status_until", "1");
  assert.equal(await badge(pane1), "", "expired leases disappear without a running extension");
  await first.update("working");
  const otherPane = await tmux("new-window", "-d", "-P", "-F", "#{pane_id}", "-n", "other", "/bin/sh");
  assert.equal(await badge(otherPane), "", "unrelated windows have no badge");
  await tmux("join-pane", "-d", "-s", pane1, "-t", otherPane);
  assert.equal(await badge(pane2), "", "moving a pane leaves no stale aggregate");
  assert.equal(await badge(otherPane), "[pi:working]");
  const replacement = create(pane1, "replacement");
  await replacement.start("waiting");
  await first.update("done");
  await first.stop();
  assert.equal(await badge(otherPane), "[pi:waiting]", "old runtimes cannot alter a successor");
  const third = create(pane2, "third");
  await third.start("done");
  const row = await tmux("display-message", "-p", "-t", pane2, windowList);
  assert.match(row, /0 editor \[pi:done\]/);
  assert.match(row, /1 other \[pi:waiting\]/, "background windows have inline badges too");
  await replacement.stop();
  assert.equal(await badge(otherPane), "");
  assert.equal(await tmux("show-options", "-p", "-t", pane1), "", "shutdown removes all pane-local state");

  assert.deepEqual(failures, [], "no tmux commands failed during the integration test");

  // Also parse the complete config, omitting only third-party plugin startup.
  await writeFile(configFile, config.replace("run -b '~/.config/tmux/plugins/tpm/tpm'", ""));
  await tmux("set-option", "-g", "status", "2");
  await tmux("source-file", configFile);
  assert.equal(await tmux("show-options", "-gv", "status"), "on");
  const bindings = await tmux("list-keys", "-T", "prefix");
  assert.match(bindings, /Space\s+set-option -g status/);
  for (const expected of ["off", "on"]) {
    await tmux("set-option", "-g", "status");
    assert.equal(await tmux("show-options", "-gv", "status"), expected);
  }
});
