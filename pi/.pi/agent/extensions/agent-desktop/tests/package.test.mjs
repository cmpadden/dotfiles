import assert from "node:assert/strict";
import { execFile } from "node:child_process";
import { readFile } from "node:fs/promises";
import { test } from "node:test";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const exec = promisify(execFile);
const packageDirectory = fileURLToPath(new URL("../", import.meta.url));
const manifest = JSON.parse(await readFile(new URL("../package.json", import.meta.url), "utf8"));

test("manifest is private, scoped, and declares host APIs only as peers/development dependencies", () => {
  assert.match(manifest.name, /^@[^/]+\/pi-agent-desktop$/);
  assert.equal(manifest.private, true, "release requires an explicit opt-in");
  assert.equal(manifest.publishConfig.access, "public");
  assert.deepEqual(manifest.pi.extensions, ["./src/index.ts"]);
  assert.deepEqual(manifest.dependencies ?? {}, {});
  assert.deepEqual(manifest.peerDependencies, {
    "@earendil-works/pi-coding-agent": "*",
    typebox: "*",
  });
  assert.equal(manifest.devDependencies["@earendil-works/pi-coding-agent"], "1.5.0", "pin the loader used by integration tests");
  assert.equal(manifest.scripts.prepare, undefined, "consumer installation must not require development tools");
});

test("npm tarball allowlist includes runtime/docs/license but no tests, tooling, lockfile or installed dependencies", async () => {
  const args = ["pack", "--dry-run", "--json", "--ignore-scripts"];
  // npm supplies its CLI path when this runs through `npm test`; no shell needed.
  const command = process.env.npm_execpath ? process.execPath : "npm";
  const commandArgs = process.env.npm_execpath ? [process.env.npm_execpath, ...args] : args;
  const { stdout } = await exec(command, commandArgs, { cwd: packageDirectory, timeout: 30_000 });
  const [packed] = JSON.parse(stdout);
  assert.deepEqual(packed.files.map((entry) => entry.path).sort(), [
    "CHANGELOG.md", "LICENSE", "README.md", "package.json", "src/index.ts", "src/runtime.ts",
  ]);
  assert.deepEqual(packed.bundled ?? [], []);
  assert.ok(packed.unpackedSize < 50 * 1024);
});
