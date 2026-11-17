// Opt-in parser/envelope checks against a separately installed, real CLI.
// Never operates an app: commands use --help, except the metadata-only version command.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { test } from "node:test";
import { buildInvocation, type DesktopInput } from "../src/runtime.ts";

const binary = process.env.PI_AGENT_DESKTOP_TEST_BIN;

test("real CLI matches the reference envelope and accepts adapter command flags", {
  skip: !binary && "Set PI_AGENT_DESKTOP_TEST_BIN to a separately installed agent-desktop executable",
}, async () => {
  const directory = await mkdtemp(join(tmpdir(), "desktop-cli-contract-"));
  const env: NodeJS.ProcessEnv = { ...process.env, AGENT_DESKTOP_HOME: join(directory, "state") };
  delete env.AGENT_DESKTOP_SESSION;
  delete env.AGENT_DESKTOP_AGENT_ID;
  const run = (args: string[]) => execFileSync(binary!, args, {
    cwd: directory, env, encoding: "utf8", timeout: 10_000,
    maxBuffer: 1024 * 1024, stdio: ["ignore", "pipe", "pipe"],
  });
  try {
    const version = JSON.parse(run(["--session=pi-contract", "version"]));
    assert.equal(version.ok, true);
    assert.equal(version.command, "version");
    assert.equal(version.version, "2.6");
    assert.equal(version.data.version, "1.3.1");

    const inputs: DesktopInput[] = [
      { command: "status" },
      { command: "list-apps", app: "Test" },
      { command: "list-windows", app: "Test" },
      { command: "snapshot", app: "Test", maxDepth: 50, skeleton: true },
      { command: "snapshot", windowId: "123", interactiveOnly: false },
      { command: "snapshot", root: "@scontract:e1" },
      { command: "get", ref: "@scontract:e1", property: "bounds" },
      { command: "click", ref: "@scontract:e1" },
      { command: "type", ref: "@scontract:e1", text: "literal --headed", headed: true },
      { command: "set-value", ref: "@scontract:e1", text: "" },
      { command: "press", app: "Test", keys: "cmd+a", headed: true },
      { command: "press", windowId: "123", keys: "return" },
      { command: "scroll", ref: "@scontract:e1", direction: "down", amount: 100 },
      { command: "screenshot", app: "Test" },
      { command: "screenshot", windowId: "123" },
    ];
    for (const input of inputs) {
      const { args } = buildInvocation(input, "pi-contract");
      // --help must precede '--', otherwise it becomes literal action text.
      const separator = args.indexOf("--");
      args.splice(separator < 0 ? args.length : separator, 0, "--help");
      assert.match(run(args), /Usage: agent-desktop/, JSON.stringify(input));
    }
    for (const action of [["enable", "--label=pi-contract"], ["disable"]]) {
      assert.match(run(["--session=pi-contract", "cursor-overlay", ...action, "--help"]), /Usage: agent-desktop/);
    }
  } finally {
    await rm(directory, { recursive: true, force: true });
  }
});
