// Loads the real extension with the installed Pi loader, but uses a fake child
// CLI. No model requests, credentials, or paid API calls are needed.
import assert from "node:assert/strict";
import { mkdtemp, readFile, realpath, rm, stat, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";

const agentDir = fileURLToPath(new URL("../../", import.meta.url));
const version = (await readFile(join(agentDir, "install/current-version"), "utf8")).trim();
const loaderPath = join(agentDir, "install/releases", version, "node_modules/@earendil-works/pi-coding-agent/dist/core/extensions/loader.js");
const { loadExtensions } = await import(pathToFileURL(loaderPath).href);
const extensionPath = fileURLToPath(new URL("index.ts", import.meta.url));

async function fixture(fn) {
  const directory = await mkdtemp(join(tmpdir(), "delegate-extension-test-"));
  const oldScript = process.argv[1];
  try {
    const loaded = await loadExtensions([extensionPath], directory);
    assert.deepEqual(loaded.errors, []);
    const extension = loaded.extensions[0];
    const tool = extension.tools.get("delegate").definition;
    const script = join(directory, "fake-pi.mjs");
    process.argv[1] = script;
    const ctx = {
      cwd: directory, thinkingLevel: "medium", isProjectTrusted: () => false,
      modelRegistry: { find: (provider, id) => provider === "test" && id === "vendor/model" ? { provider, id } : undefined },
    };
    await writeFile(script, `
      let task = ''; for await (const chunk of process.stdin) task += chunk;
      const event = {type:'message_end', message:{role:'assistant', stopReason:'stop',
        content:[{type:'text',text:JSON.stringify({task,args:process.argv.slice(2),cwd:process.cwd()})}],
        usage:{input:10,output:2,cacheRead:0,cacheWrite:0,totalTokens:12,
          cost:{input:0,output:0,cacheRead:0,cacheWrite:0,total:0}}}};
      if (task.includes('LONG_OUTPUT')) event.message.content[0].text = 'x'.repeat(60000);
      if (task.includes('FAIL')) { event.message.stopReason='error'; event.message.errorMessage='Provider unavailable'; }
      if (task.includes('WAIT')) { process.stdout.write(JSON.stringify(event)+'\\n'); setInterval(()=>{},1000); }
      else process.stdout.write(JSON.stringify(event)+'\\n');
    `);
    await fn({ tool, ctx, extension, directory });
  } finally {
    process.argv[1] = oldScript;
    await rm(directory, { recursive: true, force: true });
  }
}

test("tool loads with a small schema and forwards model/thinking/tools to an awaited child", async () => {
  await fixture(async ({ tool, ctx }) => {
    assert.equal(tool.executionMode, "sequential");
    assert.deepEqual(Object.keys(tool.parameters.properties).sort(), ["model", "task", "thinking", "tools"]);
    const result = await tool.execute("test", {
      task: "Plan this", model: "test/vendor/model", thinking: "high", tools: ["read", "grep"],
    }, undefined, undefined, ctx);
    assert.equal(result.isError, false);
    assert.equal(result.usage.input, 10);
    const child = JSON.parse(result.details.output);
    assert.equal(child.task, "Task: Plan this");
    assert.equal(child.cwd, await realpath(ctx.cwd));
    assert.equal(child.args[child.args.indexOf("--model") + 1], "vendor/model");
    assert.equal(child.args[child.args.indexOf("--thinking") + 1], "high");
    assert.equal(child.args[child.args.indexOf("--tools") + 1], "read,grep");
  });
});

test("omitted thinking inherits from the parent; tools use the documented default", async () => {
  await fixture(async ({ tool, ctx }) => {
    const result = await tool.execute("test", { task: "Implement", model: "test/vendor/model" }, undefined, undefined, ctx);
    const { args } = JSON.parse(result.details.output);
    assert.equal(args[args.indexOf("--thinking") + 1], "medium");
    assert.equal(args[args.indexOf("--tools") + 1], "read,bash,edit,write");
  });
});

test("rejects unknown, ambiguous, and blank requests before launching", async () => {
  await fixture(async ({ tool, ctx }) => {
    for (const params of [
      { task: "Do work", model: "unknown/model" },
      { task: "Do work", model: "model" },
      { task: "   ", model: "test/vendor/model" },
    ]) await assert.rejects(tool.execute("test", params, undefined, undefined, ctx));
  });
});

test("provider errors are flagged while preserving partial text and usage", async () => {
  await fixture(async ({ tool, ctx }) => {
    const result = await tool.execute("test", { task: "FAIL", model: "test/vendor/model" }, undefined, undefined, ctx);
    assert.equal(result.isError, true);
    assert.match(result.content[0].text, /Provider unavailable/);
    assert.match(result.content[0].text, /Task: FAIL/);
    assert.equal(result.usage.input, 10);
  });
});

test("large results are bounded with full output saved privately outside the repository", async () => {
  await fixture(async ({ tool, ctx }) => {
    const result = await tool.execute("test", { task: "LONG_OUTPUT", model: "test/vendor/model" }, undefined, undefined, ctx);
    const path = result.details.outputFile;
    try {
      assert.ok(Buffer.byteLength(result.content[0].text) < 52000);
      assert.match(result.content[0].text, /Output truncated/);
      assert.equal((await readFile(path, "utf8")).length, 60000);
      assert.equal((await stat(path)).mode & 0o777, 0o600);
    } finally { await rm(join(path, ".."), { recursive: true, force: true }); }
  });
});

test("session shutdown cancels and awaits active children", { timeout: 5000 }, async () => {
  await fixture(async ({ tool, ctx, extension }) => {
    let ready;
    const updated = new Promise((resolve) => { ready = resolve; });
    const run = tool.execute("test", { task: "WAIT", model: "test/vendor/model" }, undefined,
      (result) => { if (result.details.turns) ready(); }, ctx);
    await updated;
    for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
    assert.equal((await run).details.status, "aborted");
  });
});

test("child environment guard prevents registering delegate recursively", async () => {
  const previous = process.env.PI_DELEGATE_CHILD;
  process.env.PI_DELEGATE_CHILD = "1";
  try {
    const loaded = await loadExtensions([extensionPath], process.cwd());
    assert.deepEqual(loaded.errors, []);
    assert.equal(loaded.extensions[0].tools.size, 0);
  } finally {
    if (previous === undefined) delete process.env.PI_DELEGATE_CHILD;
    else process.env.PI_DELEGATE_CHILD = previous;
  }
});
