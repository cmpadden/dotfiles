import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join, relative, resolve } from "node:path";

type PackageManifest = {
  name?: string;
  pi?: { extensions?: string[] };
};

type Settings = {
  packages?: string[];
};

const agentDirectory = join(homedir(), ".pi", "agent");

function readJson<T>(path: string): T | undefined {
  try {
    return JSON.parse(readFileSync(path, "utf8")) as T;
  } catch {
    return undefined;
  }
}

function files(directory: string, suffix: string): string[] {
  if (!existsSync(directory)) return [];
  return readdirSync(directory)
    .filter((entry) => entry.endsWith(suffix))
    .map((entry) => join(directory, entry));
}

function contextFiles(cwd: string): string[] {
  const paths: string[] = [];
  const global = join(agentDirectory, "AGENTS.md");
  if (existsSync(global)) paths.push("~/.pi/agent/AGENTS.md");

  for (let directory = resolve(cwd); ; directory = resolve(directory, "..")) {
    for (const name of ["AGENTS.md", "CLAUDE.md"]) {
      const path = join(directory, name);
      if (existsSync(path)) paths.push(relative(cwd, path) || name);
    }
    if (directory === resolve(directory, "..")) break;
  }

  return paths.sort();
}

function extensionNames(): string[] {
  const names = files(join(agentDirectory, "extensions"), ".ts").map((path) => basename(path));
  const settings = readJson<Settings>(join(agentDirectory, "settings.json"));

  for (const source of settings?.packages ?? []) {
    const packageDirectory = source.startsWith("npm:")
      ? join(agentDirectory, "npm", "node_modules", source.slice(4))
      : resolve(agentDirectory, source);
    const manifest = readJson<PackageManifest>(join(packageDirectory, "package.json"));
    if (!manifest?.name) continue;

    for (const extension of manifest.pi?.extensions ?? []) {
      const name = extension.replace(/^\.\//, "");
      names.push(source.startsWith("npm:") ? `${manifest.name}:${basename(name)}` : `${manifest.name}/${name}`);
    }
  }

  return names.sort();
}

function themeNames(): string[] {
  return files(join(agentDirectory, "themes"), ".json")
    .map((path) => readJson<{ name?: string }>(path)?.name)
    .filter((name): name is string => Boolean(name))
    .sort();
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("info", {
    description: "Show loaded Pi resources",
    handler: async (_args, ctx) => {
      const prompts = pi
        .getCommands()
        .filter((command) => command.source === "prompt")
        .map((command) => `/${command.name}`)
        .sort();
      const resources: Array<[string, string[]]> = [
        ["Context", contextFiles(ctx.cwd)],
        ["Prompts", prompts],
        ["Extensions", extensionNames()],
        ["Themes", themeNames()],
      ];
      const sections = resources
        .filter(([, entries]) => entries.length > 0)
        .map(([name, entries]) => `[${name}]\n${entries.map((entry) => `    ${entry}`).join("\n")}`);

      ctx.ui.notify(sections.join("\n\n"), "info");
    },
  });
}
