// Standalone, dependency-free pane viewer; never starts another agent.
import { readFileSync, realpathSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { stripVTControlCharacters } from "node:util";

export function safeText(value) {
  return stripVTControlCharacters(String(value ?? "")).replace(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/g, "");
}

export function renderMonitor(state) {
  return safeText([
    `Delegate · ${state.status} · ${Math.floor(state.elapsedMs / 1000)}s · $${state.cost.toFixed(4)}`,
    state.label, state.model, `cwd: ${state.cwd}`,
    "Monitor only · cancel in parent Pi · closes when done", "",
    ...state.activity.slice(-6), "", state.error, state.output || "Working…",
  ].filter((line) => line !== undefined).join("\n"));
}

// Node canonicalizes import.meta.url, but argv keeps the Stow symlink path.
if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [path, owner] = process.argv.slice(2);
  const tick = () => {
    try {
      process.kill(Number(owner), 0);
      const state = JSON.parse(readFileSync(path, "utf8"));
      const lines = renderMonitor(state).split("\n");
      const rows = Math.max(1, (process.stdout.rows || 24) - 1);
      // Keep the header and newest content visible without growing scrollback.
      const headerRows = Math.min(5, rows);
      const tailRows = rows - headerRows;
      const visible = lines.length > rows
        ? [...lines.slice(0, headerRows), ...(tailRows ? lines.slice(-tailRows) : [])]
        : lines;
      const columns = Math.max(1, (process.stdout.columns || 80) - 1);
      process.stdout.write("\x1b[H\x1b[2J" + visible.map((line) => Array.from(line).slice(0, columns).join("")).join("\n"));
    } catch {
      // Parent died or removed its private snapshot. Do not leave a live viewer behind.
      process.exit(0);
    }
  };
  tick();
  setInterval(tick, 250);
}
