import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const exec = promisify(execFile);
const packageDirectory = fileURLToPath(new URL("../", import.meta.url));
const manifest = JSON.parse(await readFile(new URL("../package.json", import.meta.url), "utf8"));

// Also verifies that future changes cannot accidentally pull the tmux viewer out
// of the tarball or ship the package's development environment.
const publishedFiles = [
  "CHANGELOG.md", "LICENSE", "README.md", "package.json",
  "src/index.ts", "src/monitor-view.mjs", "src/monitor.ts", "src/queue.ts", "src/runtime.ts",
];

test("manifest is publishable under the requested scope and uses host peers rather than bundled runtime dependencies", () => {
  assert.equal(manifest.name, "@colton.padden/pi-delegate");
  assert.notEqual(manifest.private, true);
  assert.equal(manifest.publishConfig.access, "public");
  assert.deepEqual(manifest.pi.extensions, ["./src/index.ts"]);
  assert.deepEqual(manifest.dependencies ?? {}, {});
  assert.deepEqual(manifest.peerDependencies, {
    "@earendil-works/pi-ai": "*",
    "@earendil-works/pi-coding-agent": "*",
    "@earendil-works/pi-tui": "*",
    typebox: "*",
  });
  assert.equal(manifest.devDependencies["@earendil-works/pi-coding-agent"], "1.5.0");
  assert.equal(manifest.scripts.prepare, undefined, "consumer installation must not require development tools");
});

test("npm tarball contains every runtime helper and viewer but no tests, tooling, dependencies, or lockfile", async () => {
  const args = ["pack", "--dry-run", "--json", "--ignore-scripts"];
  const command = process.env.npm_execpath ? process.execPath : "npm";
  const commandArgs = process.env.npm_execpath ? [process.env.npm_execpath, ...args] : args;
  const { stdout } = await exec(command, commandArgs, { cwd: packageDirectory, timeout: 30_000 });
  const [packed] = JSON.parse(stdout);
  assert.deepEqual(packed.files.map((entry) => entry.path).sort(), [...publishedFiles].sort());
  assert.deepEqual(packed.bundled ?? [], []);
  assert.ok(packed.unpackedSize < 64 * 1024);
});

test("license retains the upstream Pi subagent attribution", async () => {
  const license = await readFile(new URL("../LICENSE", import.meta.url), "utf8");
  assert.match(license, /MIT License/);
  assert.match(license, /Copyright \(c\) 2025 Mario Zechner/);
});
