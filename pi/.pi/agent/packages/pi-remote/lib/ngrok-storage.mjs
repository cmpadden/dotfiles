import { chmod, mkdir, readFile, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { parse, stringify } from "yaml";
import { ngrokConfigPaths } from "./ngrok-auth.mjs";

export async function saveNgrokAuthtoken(token, options = {}) {
  const value = String(token || "").trim();
  if (value.length < 20 || /\s/.test(value)) throw new Error("That does not look like an ngrok authtoken");
  const path = options.path ?? ngrokConfigPaths(options.env)[0];
  let config = {};
  try {
    config = parse(await readFile(path, "utf8")) || {};
  } catch (error) {
    if (error?.code !== "ENOENT") throw error;
  }
  if (config.version === 3 || config.agent) {
    config.version = 3;
    config.agent = { ...(config.agent || {}), authtoken: value };
  } else {
    config.version = config.version || "2";
    config.authtoken = value;
  }
  await mkdir(dirname(path), { recursive: true });
  await writeFile(path, stringify(config), { mode: 0o600 });
  await chmod(path, 0o600);
  return path;
}
