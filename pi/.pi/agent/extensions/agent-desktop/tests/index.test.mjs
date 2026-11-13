// Exercise Pi's real loader and a fake desktop executable. No model or GUI calls.
import assert from "node:assert/strict";
import { access, mkdir, mkdtemp, rm, symlink, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

// Resolve the pinned development dependency, not a particular Pi installation.
// Only the tests use Pi's internal loader; the package itself uses public APIs.
const loaderUrl = new URL("./core/extensions/loader.js", import.meta.resolve("@earendil-works/pi-coding-agent"));
const { discoverAndLoadExtensions } = await import(loaderUrl.href);
const packagePath = fileURLToPath(new URL("../", import.meta.url));

async function fixture(fn) {
  const directory = await mkdtemp(join(tmpdir(), "desktop-extension-test-"));
  const binary = join(directory, "fake-desktop");
  const previous = process.env.PI_AGENT_DESKTOP_BIN;
  let extension;
  const ctx = { cwd: directory };
  try {
    await writeFile(binary, `#!${process.execPath}
      let stdin = ''; for await (const chunk of process.stdin) stdin += chunk;
      const args = process.argv.slice(2);
      const command = args.find(arg => !arg.startsWith('--'));
      console.log(JSON.stringify({version:'2.6',ok:true,command,data:{
        args,stdin,cwd:process.cwd(),root:process.env.AGENT_DESKTOP_HOME,
        parentSession:process.env.AGENT_DESKTOP_SESSION,
        parentAgent:process.env.AGENT_DESKTOP_AGENT_ID,
      }}));
    `, { mode: 0o700 });
    process.env.PI_AGENT_DESKTOP_BIN = binary;
    const agentDir = join(directory, "agent");
    await mkdir(join(agentDir, "extensions"), { recursive: true });
    await symlink(packagePath, join(agentDir, "extensions", "agent-desktop"), "dir");
    const loaded = await discoverAndLoadExtensions([], directory, agentDir);
    assert.deepEqual(loaded.errors, []);
    assert.equal(loaded.extensions.length, 1, "the manifest loads exactly one extension");
    extension = loaded.extensions[0];
    const tool = extension.tools.get("desktop").definition;
    await fn({ tool, extension, ctx, directory });
  } finally {
    if (previous === undefined) delete process.env.PI_AGENT_DESKTOP_BIN;
    else process.env.PI_AGENT_DESKTOP_BIN = previous;
    for (const handler of extension?.handlers.get("session_shutdown") ?? []) await handler({ reason: "quit" }, ctx);
    await rm(directory, { recursive: true, force: true });
  }
}
function envelope(result) {
  assert.equal(result.isError, false, JSON.stringify(result.content));
  return JSON.parse(result.content[0].text);
}

test("Pi discovers the subfolder manifest, registers one sequential typed tool, and invokes the configured binary", async () => {
  await fixture(async ({ tool, ctx }) => {
    assert.equal(tool.name, "desktop");
    assert.equal(tool.executionMode, "sequential");
    assert.equal(tool.parameters.additionalProperties, false);
    assert.deepEqual(tool.parameters.required, ["command"]);
    assert.ok(tool.parameters.properties.command.enum.includes("snapshot"));
    assert.ok(!tool.parameters.properties.command.enum.includes("batch"));
    assert.equal(tool.parameters.properties.args, undefined);
    const result = await tool.execute("test", { command: "status" }, undefined, undefined, ctx);
    const { data } = envelope(result);
    assert.deepEqual(data.args, ["--session=pi", "status"]);
    assert.equal(data.parentSession, undefined);
    assert.equal(data.parentAgent, undefined);
    assert.ok(data.root.startsWith(tmpdir()));
  });
});

test("forwards text only over stdin and opts into headed delivery explicitly", async () => {
  await fixture(async ({ tool, ctx }) => {
    const text = "literal --headed and $(echo no)\nsecond line";
    const result = await tool.execute("test", { command: "type", ref: "@s:e1", text, headed: true }, undefined, undefined, ctx);
    const { data } = envelope(result);
    assert.equal(data.stdin, text);
    assert.deepEqual(data.args, ["--session=pi", "--headed", "type", "--stdin", "--", "@s:e1"]);
    assert.equal(data.args.includes(text), false);
    const invalid = await tool.execute("test", { command: "status", headed: true }, undefined, undefined, ctx);
    assert.equal(invalid.isError, true);
  });
});

test("reload/shutdown removes private state and invalidates the old runtime", async () => {
  await fixture(async ({ tool, extension, ctx }) => {
    const result = await tool.execute("test", { command: "snapshot", app: "Test" }, undefined, undefined, ctx);
    const { data } = envelope(result);
    await access(dirname(data.root));
    for (const handler of extension.handlers.get("session_shutdown")) await handler({ reason: "reload" }, ctx);
    await assert.rejects(access(dirname(data.root)));
    const after = await tool.execute("test", { command: "status" }, undefined, undefined, ctx);
    assert.equal(after.isError, true);
  });
});
