import assert from "node:assert/strict";
import { mkdtemp, readFile, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { childArguments, runDelegate, type DelegateOptions } from "./runtime.ts";
import { DelegateQueue } from "./queue.ts";

const options: DelegateOptions = {
  task: "Inspect this task", provider: "test-provider", model: "vendor/model",
  cwd: process.cwd(), trusted: false,
};
const usage = {
  input: 10, output: 5, cacheRead: 2, cacheWrite: 1, totalTokens: 18,
  cost: { input: 0.01, output: 0.02, cacheRead: 0, cacheWrite: 0, total: 0.03 },
};
const message = (text = "Done", stopReason = "stop") => ({
  type: "message_end", message: {
    role: "assistant", content: [{ type: "text", text }], usage, stopReason,
    errorMessage: stopReason === "error" ? "Provider failed" : undefined,
  },
});
const line = (event: unknown) => `${JSON.stringify(event)}\n`;
const invocation = (script: string) => ({ command: process.execPath, args: ["--input-type=module", "-e", script, "--"] });
const emit = (event: unknown) => `process.stdout.write(${JSON.stringify(line(event))});`;
const delay = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

async function waitFor(check: () => Promise<boolean>) {
  for (let i = 0; i < 200; i++) {
    if (await check()) return;
    await delay(10);
  }
  throw new Error("Timed out waiting for child readiness");
}

test("queue preserves FIFO, skips a cancelled head waiter, and releases slots only once", async () => {
  const queue = new DelegateQueue(1);
  const signal = new AbortController().signal;
  const first = await queue.acquire(signal);
  const cancelled = new AbortController();
  const head = queue.acquire(cancelled.signal);
  const order: number[] = [];
  const second = queue.acquire(signal).then((release) => { order.push(2); return release; });
  const third = queue.acquire(signal).then((release) => { order.push(3); return release; });
  cancelled.abort();
  assert.equal(await head, undefined);
  first!();
  const releaseSecond = await second;
  assert.deepEqual(order, [2]);
  first!(); // A duplicate release must not start the third waiter.
  await Promise.resolve();
  assert.deepEqual(order, [2]);
  releaseSecond!();
  (await third)!();
  assert.deepEqual(order, [2, 3]);
});

test("child arguments pin provider/model, disable extensions, and preserve trust/tool scope", () => {
  const args = childArguments({ ...options, thinking: "high", tools: ["read", "grep"] });
  assert.ok(args.includes("--no-extensions"));
  assert.ok(args.includes("--no-session"));
  assert.ok(args.includes("--no-mcp"));
  assert.ok(args.includes("--no-approve"));
  assert.equal(args[args.indexOf("--provider") + 1], "test-provider");
  assert.equal(args[args.indexOf("--model") + 1], "vendor/model");
  assert.equal(args[args.indexOf("--tools") + 1], "read,grep");
  assert.equal(args[args.indexOf("--thinking") + 1], "high");
  assert.ok(childArguments({ ...options, trusted: true }).includes("--approve"));
});

test("awaits process exit, streams text/tools, and counts final usage once", async () => {
  let finished = false;
  const updates: string[] = [];
  const latestEvents: (string | undefined)[] = [];
  const script = [
    emit({ type: "message_start", message: { role: "assistant" } }),
    emit({ type: "message_update", assistantMessageEvent: { type: "text_delta", delta: "Working" } }),
    emit({ type: "tool_execution_start", toolName: "read", args: { path: "README.md" } }),
    `setTimeout(() => { ${emit(message())} }, 250);`,
  ].join("\n");
  const run = runDelegate(options, undefined, (d) => {
    updates.push(d.output);
    latestEvents.push(d.latestEvent);
  }, invocation(script)).then((d) => { finished = true; return d; });
  await delay(170);
  assert.equal(finished, false);
  const result = await run;
  assert.equal(result.status, "completed");
  assert.equal(result.output, "Done");
  assert.ok(updates.includes("Working"));
  assert.ok(result.activity.includes("→ read README.md"));
  assert.ok(latestEvents.includes("→ read README.md"));
  assert.equal(result.latestEvent, "Done");
  assert.deepEqual(result.usage, usage);
  assert.equal(result.turns, 1);
});

test("transmits task on stdin rather than argv and marks children", async () => {
  const task = "@not-a-file\n--option 'quoted' $HOME";
  const script = `let input = ''; for await (const chunk of process.stdin) input += chunk;
    const text = JSON.stringify({input, args: process.argv, child: process.env.PI_DELEGATE_CHILD, cwd: process.cwd()});
    const event = ${JSON.stringify(message())}; event.message.content[0].text = text;
    process.stdout.write(JSON.stringify(event));`;
  const result = await runDelegate({ ...options, task }, undefined, undefined, invocation(script));
  const parsed = JSON.parse(result.output);
  assert.equal(parsed.input, `Task: ${task}`);
  assert.ok(!parsed.args.includes(task));
  assert.equal(parsed.child, "1");
  assert.equal(parsed.cwd, process.cwd());
});

test("handles split UTF-8, CRLF, multiple text blocks, and trailing records without LF", async () => {
  const event = message("Hello 🌍\u2028world");
  event.message.content.push({ type: "text", text: "Second block" });
  const script = `const bytes = Buffer.from(${JSON.stringify(JSON.stringify(event) + "\r\n")});
    for (const byte of bytes) { process.stdout.write(Buffer.from([byte])); await new Promise(r => setTimeout(r, 1)); }`;
  const result = await runDelegate(options, undefined, undefined, invocation(script));
  assert.equal(result.output, "Hello 🌍\u2028world\nSecond block");
  assert.equal(result.status, "completed");
});

test("accumulates multiple turns but returns only the final response", async () => {
  const result = await runDelegate(options, undefined, undefined,
    invocation(emit(message("First", "toolUse")) + emit(message("Final"))));
  assert.equal(result.output, "Final");
  assert.equal(result.turns, 2);
  assert.equal(result.usage.input, 20);
});

for (const [name, script, expected] of [
  ["nonzero exit", emit(message("Partial")) + 'process.stderr.write("CLI failure"); process.exitCode = 2;', /code 2/],
  ["provider error with exit zero", emit(message("Partial", "error")), /Provider failed/],
  ["token limit", emit(message("Incomplete", "length")), /ended with length/],
  ["missing assistant response", 'process.stdout.write("{\\"type\\":\\"session\\"}\\n");', /without a final/],
  ["invalid protocol", 'process.stdout.write("not json\\n");', /invalid JSONL/],
  ["oversize incomplete record", 'process.stdout.write("x".repeat(8 * 1024 * 1024 + 1));', /exceeded 8 MiB/],
] as const) {
  test(`reports ${name} without losing diagnostics`, async () => {
    const result = await runDelegate(options, undefined, undefined, invocation(script));
    assert.equal(result.status, "failed");
    assert.match(result.error ?? "", expected);
    if (name === "nonzero exit") {
      assert.equal(result.output, "Partial");
      assert.match(result.stderr, /CLI failure/);
    }
  });
}

test("malformed event shapes fail without escaping the stream handler", async () => {
  const result = await runDelegate(options, undefined, undefined, invocation(emit({ type: "message_end" })));
  assert.equal(result.status, "failed");
  assert.match(result.error ?? "", /Invalid child event/);
});

test("progress callback failures terminate the child rather than orphaning it", async () => {
  const result = await runDelegate(options, undefined, () => { throw new Error("UI unavailable"); },
    invocation("setInterval(() => {}, 1000)"), 50);
  assert.equal(result.status, "failed");
  assert.match(result.error ?? "", /UI unavailable/);
});

test("spawn errors are failures, never success", async () => {
  const result = await runDelegate(options, undefined, undefined, { command: "/nonexistent/pi-delegate-test", args: [] });
  assert.equal(result.status, "failed");
  assert.match(result.error ?? "", /Could not start Pi/);
});

test("pre-aborted calls do not spawn", async () => {
  const result = await runDelegate(options, AbortSignal.abort(), undefined, { command: "/nonexistent/pi-delegate-test", args: [] });
  assert.equal(result.status, "aborted");
  assert.equal(result.exitCode, undefined);
});

test("cancellation escalates even after SIGTERM was successfully sent", { skip: process.platform === "win32", timeout: 5000 }, async () => {
  const directory = await mkdtemp(join(tmpdir(), "delegate-test-"));
  const ready = join(directory, "ready");
  try {
    const script = `import {writeFileSync} from 'node:fs';
      process.on('SIGTERM', () => {});
      ${emit(message("Partial progress"))}
      writeFileSync(${JSON.stringify(ready)}, 'ready'); setInterval(() => {}, 1000);`;
    const controller = new AbortController();
    const run = runDelegate(options, controller.signal, undefined, invocation(script), 50);
    await waitFor(async () => readFile(ready).then(() => true, () => false));
    controller.abort();
    const result = await run;
    assert.equal(result.status, "aborted");
    assert.equal(result.output, "Partial progress");
    assert.equal(result.exitSignal, "SIGKILL");
  } finally { await rm(directory, { recursive: true, force: true }); }
});

test("cancellation reaches ordinary descendants, not just the Pi process", { skip: process.platform === "win32", timeout: 5000 }, async () => {
  const directory = await mkdtemp(join(tmpdir(), "delegate-tree-test-"));
  const ready = join(directory, "ready");
  let descendant: number | undefined;
  try {
    const script = `import {spawn} from 'node:child_process'; import {writeFileSync} from 'node:fs';
      const child = spawn(process.execPath, ['-e', 'setInterval(() => {}, 1000)'], {stdio:'inherit'});
      writeFileSync(${JSON.stringify(ready)}, String(child.pid)); setInterval(() => {}, 1000);`;
    const controller = new AbortController();
    const run = runDelegate(options, controller.signal, undefined, invocation(script), 50);
    await waitFor(async () => readFile(ready).then((p) => { descendant = Number(p); return true; }, () => false));
    controller.abort();
    assert.equal((await run).status, "aborted");
    await waitFor(async () => { try { process.kill(descendant!, 0); return false; } catch { return true; } });
  } finally {
    if (descendant) { try { process.kill(descendant, "SIGKILL"); } catch {} }
    await rm(directory, { recursive: true, force: true });
  }
});
