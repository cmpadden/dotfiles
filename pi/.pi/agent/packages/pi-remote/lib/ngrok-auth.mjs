import { readFile } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { parse } from "yaml";

export const NGROK_AUTHTOKEN_URL = "https://dashboard.ngrok.com/get-started/your-authtoken";

export function ngrokConfigPaths(env = process.env, platform = process.platform, home = homedir()) {
  const explicit = String(env.NGROK_CONFIG || "").trim();
  const paths = explicit ? [explicit] : [];
  if (platform === "darwin") paths.push(join(home, "Library", "Application Support", "ngrok", "ngrok.yml"));
  else if (platform === "win32" && env.LOCALAPPDATA) paths.push(join(env.LOCALAPPDATA, "ngrok", "ngrok.yml"));
  else paths.push(join(env.XDG_CONFIG_HOME || join(home, ".config"), "ngrok", "ngrok.yml"));
  paths.push(join(home, ".ngrok2", "ngrok.yml"));
  return [...new Set(paths)];
}

function configToken(config) {
  const token = config?.agent?.authtoken ?? config?.authtoken;
  return typeof token === "string" && token.trim() ? token.trim() : undefined;
}

export async function resolveNgrokAuthtoken(options = {}) {
  const env = options.env ?? process.env;
  const fromEnv = String(env.NGROK_AUTHTOKEN || "").trim();
  if (fromEnv) return fromEnv;

  for (const path of options.paths ?? ngrokConfigPaths(env)) {
    try {
      const token = configToken(parse(await readFile(path, "utf8")));
      if (token) return token;
    } catch (error) {
      if (error?.code !== "ENOENT") throw new Error(`Could not read ngrok config ${path}: ${error.message}`);
    }
  }
  return undefined;
}
