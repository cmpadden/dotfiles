// Standalone, dependency-free pane viewer; never starts another agent.
import { readFileSync, realpathSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { stripVTControlCharacters } from "node:util";

export function safeText(value) {
  return stripVTControlCharacters(String(value ?? "")).replace(/[\x00-\x08\x0b-\x1f\x7f-\x9f]/g, "");
}

export function renderMonitor(state, columns = Infinity) {
  const clip = (text) => Array.from(text).slice(0, columns).join("");
  const field = (label, value) => {
    const prefix = `${label}:`.padEnd(11);
    const text = clip(prefix + safeText(value).replace(/\s+/g, " ").trim());
    const length = Math.min(label.length, text.length);
    return `\x1b[1m${text.slice(0, length)}\x1b[22m${text.slice(length)}`;
  };
  const latest = safeText(state.error || state.latestEvent || state.output || state.activity?.at(-1) || "Pending activity...")
    .trim().split("\n").filter((line) => line.trim()).at(-1) || "Pending activity...";
  return [
    field("Delegate", state.label),
    field("Model", state.model),
    field("Duration", `${Math.floor(state.elapsedMs / 1000)}s`),
    field("Cost", `$${state.cost.toFixed(4)}`),
    "", clip(latest),
  ].join("\n");
}

// Node canonicalizes import.meta.url, but argv keeps the Stow symlink path.
if (process.argv[1] && realpathSync(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const [path, owner] = process.argv.slice(2);
  const tick = () => {
    try {
      process.kill(Number(owner), 0);
      const state = JSON.parse(readFileSync(path, "utf8"));
      const columns = Math.max(1, (process.stdout.columns || 80) - 1);
      const lines = renderMonitor(state, columns).split("\n");
      const rows = Math.max(1, (process.stdout.rows || 24) - 1);
      // Keep the header and newest content visible without growing scrollback.
      const headerRows = Math.min(5, rows);
      const tailRows = rows - headerRows;
      const visible = lines.length > rows
        ? [...lines.slice(0, headerRows), ...(tailRows ? lines.slice(-tailRows) : [])]
        : lines;
      process.stdout.write("\x1b[H\x1b[2J" + visible.join("\n"));
    } catch {
      // Parent died or removed its private snapshot. Do not leave a live viewer behind.
      process.exit(0);
    }
  };
  tick();
  setInterval(tick, 250);
}
