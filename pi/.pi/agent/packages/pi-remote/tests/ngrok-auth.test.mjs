import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, readFile, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { resolveNgrokAuthtoken } from "../lib/ngrok-auth.mjs";
import { saveNgrokAuthtoken } from "../lib/ngrok-storage.mjs";

const TOKEN = "2abc_example_token_that_is_long_enough";

test("prefers NGROK_AUTHTOKEN", async () => {
  assert.deepEqual(await resolveNgrokAuthtoken({ env: { NGROK_AUTHTOKEN: TOKEN }, paths: [] }), {
    token: TOKEN,
    source: "NGROK_AUTHTOKEN",
  });
});

test("saves an owner-only v3 ngrok config", async () => {
  const dir = await mkdtemp(join(tmpdir(), "pi-remote-test-"));
  const path = join(dir, "ngrok.yml");
  await saveNgrokAuthtoken(TOKEN, { path });
  assert.match(await readFile(path, "utf8"), /authtoken:/);
  assert.deepEqual(await resolveNgrokAuthtoken({ env: {}, paths: [path] }), { token: TOKEN, source: path });
});

test("reads v3 ngrok config", async () => {
  const dir = await mkdtemp(join(tmpdir(), "pi-remote-test-"));
  const path = join(dir, "ngrok.yml");
  await writeFile(path, `version: 3\nagent:\n  authtoken: ${TOKEN}\n`);
  const resolved = await resolveNgrokAuthtoken({ env: {}, paths: [path] });
  assert.deepEqual(resolved, { token: TOKEN, source: path });
});
