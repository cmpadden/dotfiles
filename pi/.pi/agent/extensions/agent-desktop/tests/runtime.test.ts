import assert from "node:assert/strict";
import { access, readFile, stat } from "node:fs/promises";
import { dirname } from "node:path";
import { test, type TestContext } from "node:test";
import { setTimeout as delay } from "node:timers/promises";
import {
  buildInvocation as scopedInvocation, DesktopRuntime, runProcess,
  type DesktopInput, type ProcessOptions, type ProcessResult, type RunProcess,
} from "../src/runtime.ts";

function reply(command: string, data: Record<string, unknown> = {}): ProcessResult {
  return { code: 0, stderr: "", stdout: JSON.stringify({ version: "2.6", ok: true, command, data }) };
}
function text(result: Awaited<ReturnType<DesktopRuntime["execute"]>>) {
  return result.content.filter((c) => c.type === "text").map((c) => c.text).join("\n");
}
function buildInvocation(input: DesktopInput) {
  return scopedInvocation(input, "pi-test-session");
}
function fixture(t: TestContext, run: RunProcess) {
  const runtime = new DesktopRuntime("test-session", "fake-agent-desktop", async (binary, args, options) => {
    if (args[1] === "cursor-overlay") return reply("cursor-overlay", { rendered: true });
    return run(binary, args, options);
  });
  t.after(() => runtime.close());
  return runtime;
}

test("builds scoped commands and safe positional arguments", () => {
  assert.throws(() => scopedInvocation({ command: "status" }, "pi"), /namespace/);
  assert.throws(() => scopedInvocation({ command: "status" }, "pi-../escape"), /namespace/);
  assert.deepEqual(buildInvocation({ command: "status" }).args, ["--session=pi-test-session", "status"]);
  assert.deepEqual(buildInvocation({ command: "snapshot", app: "--headed" }).args, [
    "--session=pi-test-session", "snapshot", "--app=--headed", "--compact", "--max-depth=6", "--interactive-only",
  ]);
  assert.deepEqual(buildInvocation({ command: "snapshot", root: "@s123:e4", interactiveOnly: false, maxDepth: 3, skeleton: true }).args, [
    "--session=pi-test-session", "snapshot", "--compact", "--max-depth=3", "--skeleton", "--root=@s123:e4",
  ]);
  const input = { command: "type", ref: "@s123:e4", text: "--headed\n$(touch /tmp/nope)", headed: true } as const;
  const invocation = buildInvocation(input);
  assert.deepEqual(invocation.args, ["--session=pi-test-session", "--headed", "type", "--stdin", "--", "@s123:e4"]);
  assert.equal(invocation.stdin, input.text);
  assert.deepEqual(buildInvocation({ command: "press", keys: "--headed", windowId: "12" }).args, [
    "--session=pi-test-session", "press", "--window-id=12", "--", "--headed",
  ]);
  assert.deepEqual(buildInvocation({ command: "scroll", ref: "@s:e1" }).args, [
    "--session=pi-test-session", "scroll", "--direction=down", "--amount=3", "--", "@s:e1",
  ]);
  assert.deepEqual(buildInvocation({ command: "get", ref: "@s:e1", property: "value" }).args, [
    "--session=pi-test-session", "get", "--property=value", "--", "@s:e1",
  ]);
  assert.equal(buildInvocation({ command: "set-value", ref: "@s:e1", text: "" }).stdin, "");
});

test("rejects unsupported, ambiguous, malformed, and irrelevant inputs before execution", () => {
  const invalid = [
    { command: "batch" }, { command: "snapshot" }, { command: "screenshot" },
    { command: "press", keys: "return" }, { command: "press", app: "Test" },
    { command: "click" }, { command: "click", ref: "@e1" },
    { command: "click", ref: "--headed" }, { command: "get", ref: "@s:e1", property: "bad" },
    { command: "status", args: ["--headed"] }, { command: "status", headed: false },
    { command: "type", ref: "@s:e1", text: "" }, { command: "set-value", ref: "@s:e1" },
    { command: "type", ref: "@s:e1", text: "é".repeat(5001) },
    { command: "set-value", ref: "@s:e1", text: "\0" },
    { command: "snapshot", app: "Test", maxDepth: 0 }, { command: "snapshot", app: "Test", maxDepth: 1.5 },
    { command: "snapshot", app: "Test", root: "@e1" }, { command: "snapshot", app: "Test", interactiveOnly: "false" },
    { command: "status", timeoutMs: NaN }, { command: "status", timeoutMs: 60_001 },
    { command: "scroll", ref: "@s:e1", amount: 0 }, { command: "scroll", ref: "@s:e1", direction: "bad" },
    { command: "list-apps", app: "\0" },
  ];
  for (const input of invalid) assert.throws(() => buildInvocation(input as DesktopInput), JSON.stringify(input));
});

test("creates private isolated state lazily, preserves envelope, and cleans up", async (t) => {
  const calls: ProcessOptions[] = [];
  const runtime = fixture(t, async (binary, args, options) => {
    assert.equal(binary, "fake-agent-desktop");
    assert.deepEqual(args, ["--session=pi-test-session", "status"]);
    calls.push(options);
    return reply("status", { permissions: { accessibility: false } });
  });
  assert.equal(calls.length, 0);
  const result = await runtime.execute({ command: "status" }, process.cwd());
  assert.equal(result.isError, false);
  assert.deepEqual(JSON.parse(text(result)).data, { permissions: { accessibility: false } });
  const root = calls[0].env.AGENT_DESKTOP_HOME!;
  assert.match(root, /pi-agent-desktop-/);
  assert.equal(calls[0].env.AGENT_DESKTOP_SESSION, undefined);
  assert.equal(calls[0].env.AGENT_DESKTOP_AGENT_ID, undefined);
  if (process.platform !== "win32") assert.equal((await stat(dirname(root))).mode & 0o777, 0o700);
  await runtime.execute({ command: "status" }, process.cwd());
  assert.equal(calls[1].env.AGENT_DESKTOP_HOME, root);
  assert.equal(calls[0].timeout, 15_000);
  await runtime.close();
  await assert.rejects(access(dirname(root)));
  assert.equal((await runtime.execute({ command: "status" }, process.cwd())).isError, true);
  assert.equal(calls.length, 2);
});

test("preserves upstream errors and retry disposition without retrying", async (t) => {
  let calls = 0;
  const error = { code: "STALE_REF", message: "expired", disposition: { delivery: "not_delivered", retry: "safe" } };
  const runtime = fixture(t, async () => {
    calls++;
    return { code: 1, stderr: "", stdout: JSON.stringify({ version: "2.6", command: "click", ok: false, error }) };
  });
  const result = await runtime.execute({ command: "click", ref: "@s:e1" }, process.cwd());
  assert.equal(result.isError, true);
  assert.deepEqual(JSON.parse(text(result)).error, error);
  assert.equal(calls, 1);
});

test("handles missing CLI, termination, invalid JSON, invalid envelopes and inconsistent exits", async (t) => {
  for (const [processResult, expected] of [
    [{ stdout: "", stderr: "", code: 1, missing: true }, /not found/],
    [{ stdout: "", stderr: "", code: 1, stopped: true }, /Delivery may be uncertain/],
    [{ stdout: "oops", stderr: "CLI diagnostic", code: 1 }, /invalid JSON.*CLI diagnostic/],
    [{ stdout: "null", stderr: "", code: 0 }, /Unexpected.*envelope/],
    [{ ...reply("click"), code: 0 }, /Unexpected.*envelope/],
    [{ ...reply("status"), code: 4 }, /exited with code 4/],
  ] as const) {
    const runtime = fixture(t, async () => processResult);
    const result = await runtime.execute({ command: "status" }, process.cwd());
    assert.equal(result.isError, true);
    assert.match(text(result), expected);
  }
});

test("bounds output and retains full JSON only in private temporary storage", async (t) => {
  const data = { complete: false, tree: "界".repeat(30_000) };
  const runtime = fixture(t, async () => reply("snapshot", data));
  const result = await runtime.execute({ command: "snapshot", app: "Test" }, process.cwd());
  assert.equal(result.isError, false);
  assert.equal(result.details.truncated, true);
  assert.ok(Buffer.byteLength(text(result)) < 53_000);
  assert.match(text(result), /Full JSON:/);
  const path = result.details.fullOutputPath!;
  assert.deepEqual(JSON.parse(await readFile(path, "utf8")).data, data);
  if (process.platform !== "win32") assert.equal((await stat(path)).mode & 0o777, 0o600);
  await runtime.close();
  await assert.rejects(access(path));
});

const png = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jBqkAAAAASUVORK5CYII=";
test("attaches screenshot images without duplicating base64 in text or details", async (t) => {
  const runtime = fixture(t, async () => reply("screenshot", { data: png, format: "png", width: 1, height: 1 }));
  const result = await runtime.execute({ command: "screenshot", windowId: "1" }, process.cwd());
  assert.equal(result.isError, false);
  assert.deepEqual(result.content[1], { type: "image", data: png, mimeType: "image/png" });
  assert.equal(text(result).includes(png), false);
  assert.equal(JSON.stringify(result.details).includes(png), false);
  assert.equal(JSON.parse(text(result)).data.width, 1);
});

test("rejects malformed or oversized screenshot payloads", async (t) => {
  for (const data of [
    { data: png, format: "jpeg" }, { data: "aGVsbG8=", format: "png" },
    { data: "!!!!", format: "png" }, { data: "a".repeat(12 * 1024 * 1024), format: "png" }, {},
  ]) {
    const runtime = fixture(t, async () => reply("screenshot", data));
    const result = await runtime.execute({ command: "screenshot", app: "Test" }, process.cwd());
    assert.equal(result.isError, true);
    assert.equal(result.content.length, 1);
  }
});

test("serializes calls and cancellation skips queued work without poisoning the queue", async (t) => {
  const calls: string[] = [];
  let release!: () => void;
  let started!: () => void;
  const ready = new Promise<void>((resolve) => { started = resolve; });
  const runtime = fixture(t, async (_binary, args) => {
    const command = args[1];
    calls.push(command);
    if (calls.length === 1) { started(); await new Promise<void>((resolve) => { release = resolve; }); }
    return reply(command);
  });
  const first = runtime.execute({ command: "status" }, process.cwd());
  await ready;
  const controller = new AbortController();
  const second = runtime.execute({ command: "click", ref: "@s:e1" }, process.cwd(), controller.signal);
  const third = runtime.execute({ command: "list-apps" }, process.cwd());
  controller.abort();
  assert.deepEqual(calls, ["status"]);
  release();
  assert.equal((await first).isError, false);
  assert.equal((await second).isError, true);
  assert.equal((await third).isError, false);
  assert.deepEqual(calls, ["status", "list-apps"]);
});

test("shutdown aborts active work, skips queued work, and removes state after execution", async (t) => {
  let started!: () => void;
  const ready = new Promise<void>((resolve) => { started = resolve; });
  let root = "";
  let calls = 0;
  const runtime = fixture(t, async (_binary, _args, options) => {
    calls++;
    root = options.env.AGENT_DESKTOP_HOME!;
    started();
    await new Promise<void>((resolve) => options.signal.addEventListener("abort", () => resolve(), { once: true }));
    return { stdout: "", stderr: "", code: 1, stopped: true };
  });
  const first = runtime.execute({ command: "status" }, process.cwd());
  await ready;
  const second = runtime.execute({ command: "status" }, process.cwd());
  await Promise.all([runtime.close(), runtime.close()]);
  assert.equal((await first).isError, true);
  assert.equal((await second).isError, true);
  assert.equal(calls, 1);
  await assert.rejects(access(dirname(root)));
});

test("enables cursors once per Pi namespace and disables before removing state", async (t) => {
  const calls: { args: string[]; options: ProcessOptions }[] = [];
  const runtime = new DesktopRuntime("cursor-test", "fake", async (_binary, args, options) => {
    calls.push({ args, options });
    await access(dirname(options.env.AGENT_DESKTOP_HOME!));
    return reply(args[1], { rendered: true });
  });
  t.after(() => runtime.close());
  assert.equal(calls.length, 0);
  await runtime.execute({ command: "status" }, process.cwd());
  await runtime.execute({ command: "status" }, process.cwd());
  await Promise.all([runtime.close(), runtime.close()]);
  assert.deepEqual(calls.map(c => c.args), [
    ["--session=pi-cursor-test", "cursor-overlay", "enable", "--label=pi-cursor-test"],
    ["--session=pi-cursor-test", "status"],
    ["--session=pi-cursor-test", "status"],
    ["--session=pi-cursor-test", "cursor-overlay", "disable"],
  ]);
  assert.equal(calls[3].options.signal.aborted, false);
  assert.ok(calls.every(c => c.options.env.AGENT_DESKTOP_HOME === calls[0].options.env.AGENT_DESKTOP_HOME));
  await assert.rejects(access(dirname(calls[0].options.env.AGENT_DESKTOP_HOME!)));
});

test("cursor failures do not block observations or change action delivery", async (t) => {
  for (const failure of [
    { stdout: "", stderr: "unsupported", code: 1 },
    reply("cursor-overlay", { rendered: false }),
    { stdout: "", stderr: "", code: 1, stopped: true },
  ]) {
    const calls: string[][] = [];
    const runtime = new DesktopRuntime("cursor-failure", "fake", async (_binary, args) => {
      calls.push(args);
      return args[1] === "cursor-overlay" ? failure : reply(args[1]);
    });
    t.after(() => runtime.close());
    const result = await runtime.execute({ command: "status" }, process.cwd());
    assert.equal(result.isError, false);
    assert.match(result.details.cursorWarning!, /unavailable/);
    const action = await runtime.execute({ command: "click", ref: "@s:e1" }, process.cwd());
    assert.equal(action.isError, false);
    assert.deepEqual(calls[2], ["--session=pi-cursor-failure", "click", "--", "@s:e1"]);
    assert.equal(calls.filter(args => args.includes("enable")).length, 1);
    await runtime.close();
    assert.equal(calls.at(-1)![2], "disable");
  }
});

test("shutdown during cursor setup still disables the renderer without delivering the command", async () => {
  let started!: () => void;
  const ready = new Promise<void>(resolve => { started = resolve; });
  const calls: string[][] = [];
  const runtime = new DesktopRuntime("cancel-setup", "fake", async (_binary, args, options) => {
    calls.push(args);
    if (args[2] === "enable") {
      started();
      await new Promise<void>(resolve => options.signal.addEventListener("abort", () => resolve(), { once: true }));
      return { stdout: "", stderr: "", code: 1, stopped: true };
    }
    assert.equal(options.signal.aborted, false);
    return reply("cursor-overlay");
  });
  const pending = runtime.execute({ command: "status" }, process.cwd());
  await ready;
  await runtime.close();
  assert.equal((await pending).isError, true);
  assert.deepEqual(calls.map(args => args[2]), ["enable", "disable"]);
});

test("invalid or pre-cancelled calls never start a cursor renderer", async () => {
  let calls = 0;
  const runtime = new DesktopRuntime("unused", "fake", async () => { calls++; return reply("status"); });
  await runtime.execute({ command: "click" }, process.cwd());
  await runtime.execute({ command: "status" }, process.cwd(), AbortSignal.abort());
  await runtime.close();
  assert.equal(calls, 0);
});

function processOptions(overrides: Partial<ProcessOptions> = {}): ProcessOptions {
  return { cwd: process.cwd(), env: process.env, signal: new AbortController().signal, timeout: 3000, maxBuffer: 1024 * 1024, ...overrides };
}
test("real subprocess uses stdin, literal argv, and captures nonzero exits", async () => {
  const script = "let text=''; for await (const chunk of process.stdin) text+=chunk; console.log(JSON.stringify({text,args:process.argv.slice(1)})); process.exitCode=3;";
  const result = await runProcess(process.execPath, ["--input-type=module", "-e", script, "--", "$(echo nope)"], processOptions({ stdin: "secret\n--headed" }));
  assert.equal(result.code, 3);
  assert.deepEqual(JSON.parse(result.stdout), { text: "secret\n--headed", args: ["$(echo nope)"] });
});

test("real subprocess handles missing executable, timeouts, abort, output overflow and early stdin close", async () => {
  const missing = await runProcess("/nonexistent/pi-desktop-test", [], processOptions());
  assert.equal(missing.missing, true);
  const timeout = await runProcess(process.execPath, ["-e", "setInterval(()=>{},1000)"], processOptions({ timeout: 150 }));
  assert.equal(timeout.stopped, true);
  const controller = new AbortController();
  const pending = runProcess(process.execPath, ["-e", "setInterval(()=>{},1000)"], processOptions({ signal: controller.signal }));
  await delay(100);
  controller.abort();
  assert.equal((await pending).stopped, true);
  const overflow = await runProcess(process.execPath, ["-e", "console.log('x'.repeat(100000))"], processOptions({ maxBuffer: 1024 }));
  assert.equal(overflow.stopped, true);
  const earlyExit = await runProcess(process.execPath, ["-e", "process.exit(0)"], processOptions({ stdin: "x".repeat(128 * 1024) }));
  assert.equal(earlyExit.code, 0);
  const preAborted = await runProcess(process.execPath, ["-e", "throw Error('should not run')"], processOptions({ signal: AbortSignal.abort() }));
  assert.equal(preAborted.stopped, true);
});
