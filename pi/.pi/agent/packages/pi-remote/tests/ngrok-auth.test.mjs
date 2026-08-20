import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { resolveNgrokAuthtoken } from "../lib/ngrok-auth.mjs";
import { saveNgrokAuthtoken } from "../lib/ngrok-storage.mjs";

const TOKEN = "2abc_example_token_that_is_long_enough";

test("prefers NGROK_AUTHTOKEN", async () => {
  assert.equal(await resolveNgrokAuthtoken({ env: { NGROK_AUTHTOKEN: TOKEN }, paths: [] }), TOKEN);
});

test("saves an owner-only v3 ngrok config", async () => {
  const dir = await mkdtemp(join(tmpdir(), "pi-remote-test-"));
  const path = join(dir, "ngrok.yml");
  await saveNgrokAuthtoken(TOKEN, { path });
  assert.match(await readFile(path, "utf8"), /authtoken:/);
  assert.equal(await resolveNgrokAuthtoken({ env: {}, paths: [path] }), TOKEN);
});

test("reads v3 ngrok config", async () => {
  const dir = await mkdtemp(join(tmpdir(), "pi-remote-test-"));
  const path = join(dir, "ngrok.yml");
  await writeFile(path, `version: 3\nagent:\n  authtoken: ${TOKEN}\n`);
  const resolved = await resolveNgrokAuthtoken({ env: {}, paths: [path] });
  assert.equal(resolved, TOKEN);
});
