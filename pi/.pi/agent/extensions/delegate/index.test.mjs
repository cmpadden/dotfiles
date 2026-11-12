// Loads the real extension with the installed Pi loader, but uses a fake child
// CLI. No model requests, credentials, or paid API calls are needed.
import assert from "node:assert/strict";
import { mkdir, mkdtemp, readFile, realpath, rm, stat, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { fileURLToPath, pathToFileURL } from "node:url";
import { stripVTControlCharacters } from "node:util";

const agentDir = fileURLToPath(new URL("../../", import.meta.url));
const version = (await readFile(join(agentDir, "install/current-version"), "utf8")).trim();
const loaderPath = join(agentDir, "install/releases", version, "node_modules/@earendil-works/pi-coding-agent/dist/core/extensions/loader.js");
const { loadExtensions } = await import(pathToFileURL(loaderPath).href);
const extensionPath = fileURLToPath(new URL("index.ts", import.meta.url));

async function fixture(fn, config) {
  const directory = await mkdtemp(join(tmpdir(), "delegate-extension-test-"));
  const oldScript = process.argv[1];
  try {
    const loaded = await loadExtensions([extensionPath], directory);
    assert.deepEqual(loaded.errors, []);
    loaded.runtime.getSettings = () => config === undefined ? {} : { "pi-delegate": config };
    const extension = loaded.extensions[0];
    const tool = extension.tools.get("delegate").definition;
    const script = join(directory, "fake-pi.mjs");
    process.argv[1] = script;
    const ctx = {
      cwd: directory, thinkingLevel: "medium", isProjectTrusted: () => false,
      modelRegistry: { find: (provider, id) => provider === "test" && id === "vendor/model" ? { provider, id } : undefined },
    };
    await writeFile(script, `
      import {existsSync, writeFileSync} from 'node:fs';
      let task = ''; for await (const chunk of process.stdin) task += chunk;
      const event = {type:'message_end', message:{role:'assistant', stopReason:'stop',
        content:[{type:'text',text:JSON.stringify({task,args:process.argv.slice(2),cwd:process.cwd()})}],
        usage:{input:10,output:2,cacheRead:0,cacheWrite:0,totalTokens:12,
          cost:{input:0,output:0,cacheRead:0,cacheWrite:0,total:0}}}};
      if (task.includes('LONG_OUTPUT')) event.message.content[0].text = 'x'.repeat(60000);
      if (task.includes('FAIL')) { event.message.stopReason='error'; event.message.errorMessage='Provider unavailable'; }
      if (task.startsWith('Task: HOLD:')) {
        const id = task.slice('Task: HOLD:'.length);
        writeFileSync(id+'.started', String(process.pid));
        const timer = setInterval(() => {
          if (existsSync(id+'.release')) { clearInterval(timer); process.stdout.write(JSON.stringify(event)+'\\n'); }
        }, 10);
      }
      else if (task.includes('WAIT')) { process.stdout.write(JSON.stringify(event)+'\\n'); setInterval(()=>{},1000); }
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
    assert.equal(tool.executionMode, "parallel");
    assert.ok(tool.promptGuidelines.includes("Avoid delegating trivial work unless the user explicitly requests delegation, including for testing."));
    assert.deepEqual(Object.keys(tool.parameters.properties).sort(), ["cwd", "label", "model", "task", "thinking", "tools"]);
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

test("only pi-delegate.display enables monitors; legacy environment is ignored and unavailable tmux falls back", async () => {
  const oldDisplay = process.env.PI_DELEGATE_DISPLAY;
  try {
    for (const legacy of ["tmux", "hidden"]) {
      process.env.PI_DELEGATE_DISPLAY = legacy;
      for (const config of [undefined, null, "tmux", [], {}, { display: "hidden" }, { display: "invalid" }, { display: true }, { display: "tmux" }]) {
        await fixture(async ({ tool, ctx, extension }) => {
          assert.equal(extension.commands.has("delegate-display"), false);
          const notices = [];
          ctx.hasUI = true;
          ctx.ui = { notify: (text) => notices.push(text) };
          const oldPane = process.env.TMUX_PANE;
          process.env.TMUX_PANE = "";
          try {
            const result = await tool.execute("test", { task: "Inspect", model: "test/vendor/model" }, undefined, undefined, ctx);
            assert.equal(result.isError, false);
            assert.equal(result.details.status, "completed");
            assert.equal(notices.some((text) => text.includes("continuing hidden")), config?.display === "tmux");
          } finally {
            if (oldPane === undefined) delete process.env.TMUX_PANE;
            else process.env.TMUX_PANE = oldPane;
          }
        }, config);
      }
    }
  } finally {
    if (oldDisplay === undefined) delete process.env.PI_DELEGATE_DISPLAY;
    else process.env.PI_DELEGATE_DISPLAY = oldDisplay;
  }
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
      { task: "Do work", model: "test/vendor/model", cwd: "   " },
      { task: "Do work", model: "test/vendor/model", cwd: "missing-directory" },
      { task: "Do work", model: "test/vendor/model", cwd: "fake-pi.mjs" },
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

async function waitFor(check) {
  const deadline = Date.now() + 5000;
  while (Date.now() < deadline) {
    if (await check()) return;
    await new Promise((resolve) => setTimeout(resolve, 10));
  }
  throw new Error("Timed out waiting for child readiness");
}
const exists = (path) => stat(path).then(() => true, () => false);

test("explicit cwd resolves relative paths and symlinks without transferring parent trust", async () => {
  await fixture(async ({ tool, ctx, directory }) => {
    const workspace = join(directory, "separate worktree");
    await mkdir(workspace);
    await symlink(workspace, join(directory, "alias"));
    ctx.isProjectTrusted = () => true;
    const invoke = (cwd) => tool.execute("test", { task: "Inspect", model: "test/vendor/model", cwd }, undefined, undefined, ctx);
    const same = JSON.parse((await invoke(".")).details.output);
    assert.ok(same.args.includes("--approve"));
    for (const cwd of ["separate worktree", workspace, "@alias"]) {
      const result = await invoke(cwd);
      const child = JSON.parse(result.details.output);
      assert.equal(child.cwd, await realpath(workspace));
      assert.equal(result.details.cwd, child.cwd);
      assert.ok(child.args.includes("--no-approve"));
      assert.ok(!child.args.includes("--approve"));
      assert.ok(result.details.elapsedMs >= 0);
      assert.ok(result.details.queuedMs >= 0);
    }
  });
});

test("three children overlap, excess calls queue, and queued cancellation never spawns", { timeout: 10000 }, async () => {
  await fixture(async ({ tool, ctx, directory, extension }) => {
    const updates = new Map();
    const controllers = Array.from({ length: 5 }, () => new AbortController());
    const runs = [];
    try {
      // Serialize submission through preflight, not execution: filesystem path
      // validation is asynchronous and need not finish in invocation order.
      for (const [id, controller] of controllers.entries()) {
        runs.push(tool.execute(String(id), {
          task: `HOLD:${id}`, model: "test/vendor/model", tools: ["read"],
        }, controller.signal, (update) => updates.set(id, update.details), ctx));
        await waitFor(async () => updates.has(id));
      }
      await waitFor(async () => (await Promise.all([0, 1, 2].map((id) => exists(join(directory, `${id}.started`))))).every(Boolean));
      assert.equal(updates.get(3).status, "queued");
      assert.equal(updates.get(4).status, "queued");
      assert.equal(await exists(join(directory, "3.started")), false);
      assert.equal(await exists(join(directory, "4.started")), false);
      controllers[4].abort();
      const cancelled = await runs[4];
      assert.equal(cancelled.details.status, "aborted");
      assert.equal(cancelled.details.exitCode, undefined);
      await writeFile(join(directory, "0.release"), "");
      assert.equal((await runs[0]).details.status, "completed");
      await waitFor(() => exists(join(directory, "3.started")));
      for (const id of [1, 2, 3]) await writeFile(join(directory, `${id}.release`), "");
      const results = await Promise.all(runs);
      assert.deepEqual(results.map((result) => result.details.status), ["completed", "completed", "completed", "completed", "aborted"]);
      assert.equal(await exists(join(directory, "4.started")), false);
    } finally {
      for (const controller of controllers) controller.abort();
      for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
      await Promise.allSettled(runs);
    }
  });
});

test("shutdown cancels running and queued calls, and rejects later launches", { timeout: 10000 }, async () => {
  await fixture(async ({ tool, ctx, directory, extension }) => {
    const states = new Map();
    const runs = [];
    try {
      for (let id = 0; id < 5; id++) {
        runs.push(tool.execute(String(id), {
          task: `HOLD:${id}`, model: "test/vendor/model",
        }, undefined, (update) => states.set(id, update.details.status), ctx));
        await waitFor(async () => states.has(id));
      }
      await waitFor(async () => (await Promise.all([0, 1, 2].map((id) => exists(join(directory, `${id}.started`))))).every(Boolean));
      assert.equal(states.get(3), "queued");
      for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
      assert.ok((await Promise.all(runs)).every((result) => result.details.status === "aborted"));
      for (const id of [3, 4]) assert.equal(await exists(join(directory, `${id}.started`)), false);
      await assert.rejects(tool.execute("later", { task: "Inspect", model: "test/vendor/model" }, undefined, undefined, ctx), /shutting down/);
    } finally {
      for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
      await Promise.allSettled(runs);
    }
  });
});

test("child failures and progress exceptions release queue capacity", { timeout: 10000 }, async () => {
  await fixture(async ({ tool, ctx }) => {
    for (let i = 0; i < 4; i++) {
      const failed = await tool.execute(`fail-${i}`, { task: "FAIL", model: "test/vendor/model" }, undefined, undefined, ctx);
      assert.equal(failed.isError, true);
    }
    await assert.rejects(tool.execute("ui-error", { task: "Inspect", model: "test/vendor/model" }, undefined,
      () => { throw new Error("UI failed"); }, ctx), /UI failed/);
    const result = await tool.execute("after", { task: "Inspect", model: "test/vendor/model" }, undefined, undefined, ctx);
    assert.equal(result.details.status, "completed");
  });
});

test("quiet running and queued children publish live timing and stop updates after shutdown", { timeout: 10000 }, async () => {
  await fixture(async ({ tool, ctx, extension }) => {
    const updates = new Map();
    let updateCount = 0;
    const runs = [];
    try {
      for (let id = 0; id < 4; id++) {
        runs.push(tool.execute(String(id), { task: `HOLD:${id}`, model: "test/vendor/model" }, undefined,
          (update) => { updates.set(id, update.details); updateCount++; }, ctx));
        await waitFor(async () => updates.has(id));
      }
      const firstSnapshot = updates.get(0);
      const firstElapsed = firstSnapshot.elapsedMs;
      await waitFor(async () => updates.get(0).elapsedMs >= 1000 && updates.get(3).queuedMs >= 1000);
      assert.equal(updates.get(0).status, "running");
      assert.equal(updates.get(3).status, "queued");
      assert.equal(firstSnapshot.elapsedMs, firstElapsed); // Emitted snapshots remain immutable.
      for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
      await Promise.all(runs);
      const count = updateCount;
      await new Promise((resolve) => setTimeout(resolve, 1100));
      assert.equal(updateCount, count);
    } finally {
      for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
      await Promise.allSettled(runs);
    }
  });
});

test("pre-aborted tool calls never start children", async () => {
  await fixture(async ({ tool, ctx, directory }) => {
    const result = await tool.execute("test", { task: "HOLD:cancelled", model: "test/vendor/model" }, AbortSignal.abort(), undefined, ctx);
    assert.equal(result.details.status, "aborted");
    assert.equal(await exists(join(directory, "cancelled.started")), false);
  });
});

test("collapsed delegate rows stay two lines and expansion reveals details", async () => {
  await fixture(async ({ tool, ctx }) => {
    const theme = { fg: (_color, text) => text, bold: (text) => text };
    const args = { model: "test/vendor/model", label: "Check CI\nfor PRs #6182–6184",
      task: "User explicitly requests checking CI. Handle ONLY PRs #6182–6184. Do not modify files.",
    };
    const result = await tool.execute("test", args, undefined, undefined, ctx);
    assert.equal(JSON.parse(result.details.output).task, `Task: ${args.task}`);
    assert.ok(tool.promptGuidelines.some((guideline) => guideline.includes("short label derived from its task")));
    const state = {};
    const context = { args, state, cwd: ctx.cwd, expanded: false };
    assert.deepEqual(tool.renderCall(args, theme, context).render(200), [
      "delegate model", "Check CI for PRs #6182–6184",
    ]);
    for (const status of ["queued", "running", "completed", "failed", "aborted"]) {
      const details = { ...result.details, status, queuedMs: 2100, elapsedMs: 41000,
        usage: { ...result.details.usage, cost: { total: 0.1234 } },
        activity: ["→ bash a very long command\nwith multiple lines", "✓ bash"],
      };
      // Match Pi's composition order: call first, result second, then render.
      const header = tool.renderCall(args, theme, context);
      const body = tool.renderResult({ ...result, details }, { expanded: false }, theme, context);
      assert.deepEqual(body.render(200), []);
      assert.deepEqual(header.render(200), [
        `delegate model · ${status} ${status === "queued" ? "2s" : "41s"} · $0.12`,
        "Check CI for PRs #6182–6184",
      ]);
      const narrow = header.render(20);
      assert.equal(narrow.length, 2);
      assert.ok(narrow.every((line) => stripVTControlCharacters(line).length <= 20));

      const expandedContext = { ...context, expanded: true };
      const expandedHeader = tool.renderCall(args, theme, expandedContext);
      const expanded = tool.renderResult({ ...result, details }, { expanded: true }, theme, expandedContext).render(10000).join("\n");
      const expandedTitle = expandedHeader.render(200).map((line) => line.trimEnd()).join("\n");
      assert.match(expandedTitle, /delegate test\/vendor\/model/);
      assert.ok(expandedTitle.includes(args.task));
      assert.ok(expandedTitle.includes("Check CI for PRs #6182–6184"));
      assert.match(expanded, /41s elapsed · 2s queued/);
      assert.ok(expanded.includes(result.details.cwd));
      assert.ok(expanded.includes("turns · ↑10 ↓2 · $0.1234"));
      assert.ok(details.activity.join("\n").split("\n").every((line) => expanded.includes(line)));
      assert.ok(expanded.includes(result.content[0].text));
    }
  });
});

test("errors without delegate details stay compact but can be expanded", async () => {
  await fixture(async ({ tool, ctx }) => {
    const theme = { fg: (_color, text) => text, bold: (text) => text };
    const args = { model: "test/vendor/model", task: "Inspect" };
    const context = { args, state: {}, cwd: ctx.cwd, isError: true, expanded: false };
    const result = { content: [{ type: "text", text: "Unknown model" }] };
    const header = tool.renderCall(args, theme, context);
    assert.deepEqual(tool.renderResult(result, { expanded: false }, theme, context).render(200), []);
    assert.deepEqual(header.render(200), ["delegate model · failed", "Inspect"]);
    assert.deepEqual(tool.renderResult(result, { expanded: true }, theme, context).render(200).map((line) => line.trimEnd()), ["Unknown model"]);
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
