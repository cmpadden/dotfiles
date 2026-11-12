import { execFile } from "node:child_process";
import { mkdtemp, rm } from "node:fs/promises";
import { renameSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";
import type { DelegateDetails } from "./runtime.ts";

const exec = promisify(execFile);
export type TmuxCommand = (args: string[]) => Promise<string>;
const tmux: TmuxCommand = async (args) => (await exec("tmux", args, {
  timeout: 2000, maxBuffer: 16384,
})).stdout.trim();

interface PaneGroup {
  panes: string[];
  pending: Promise<void>;
}

// Serialize layout changes per parent, including simultaneous delegate launches.
const groups = new WeakMap<TmuxCommand, Map<string, PaneGroup>>();
async function withPaneGroup<T>(target: string, command: TmuxCommand, action: (group: PaneGroup) => Promise<T>): Promise<T> {
  let parents = groups.get(command);
  if (!parents) groups.set(command, parents = new Map());
  let group = parents.get(target);
  if (!group) parents.set(target, group = { panes: [], pending: Promise.resolve() });
  const previous = group.pending;
  let release!: () => void;
  const pending = group.pending = new Promise<void>((resolve) => { release = resolve; });
  await previous;
  try {
    return await action(group);
  } finally {
    release();
    if (group.pending === pending && group.panes.length === 0) parents.delete(target);
  }
}

async function balanceMonitors(target: string, command: TmuxCommand, group: PaneGroup): Promise<void> {
  if (group.panes.length < 2) return;
  const live = (await command(["list-panes", "-t", target, "-F", "#{pane_id} #{pane_top} #{pane_height}"]))
    .split("\n").map((line) => line.trim().split(/\s+/));
  const monitors = live.filter(([id]) => group.panes.includes(id))
    .map(([id, top, height]) => ({ id, top: Number(top), height: Number(height) }))
    .sort((a, b) => a.top - b.top);
  group.panes = monitors.map(({ id }) => id);
  if (monitors.length < 2) return;
  const rows = monitors.reduce((sum, pane) => sum + pane.height, 0);
  const height = Math.floor(rows / monitors.length);
  const remainder = rows % monitors.length;
  // Resize only monitor panes, never select a window-wide layout.
  for (let i = 0; i < monitors.length - 1; i++) {
    await command(["resize-pane", "-t", monitors[i].id, "-y", String(height + (i < remainder ? 1 : 0))]);
  }
}

export interface DelegateMonitor {
  update(details: DelegateDetails): void;
  close(): Promise<void>;
}

// The pane is only a viewer. Closing it never interrupts the parent-owned child.
export async function openMonitor(
  label: string,
  details: DelegateDetails,
  target = process.env.TMUX_PANE,
  command: TmuxCommand = tmux,
): Promise<DelegateMonitor> {
  if (!target || !/^%\d+$/.test(target)) throw new Error("Not inside a tmux pane.");
  const directory = await mkdtemp(join(tmpdir(), "pi-delegate-monitor-"));
  const path = join(directory, "state.json");
  let pane: string | undefined;
  let closed = false;
  let writable = true;
  const update = (state: DelegateDetails) => {
    if (closed || !writable) return;
    try {
      // Atomic, bounded snapshots: no growing logs and no partially read JSON.
      writeFileSync(`${path}.tmp`, JSON.stringify({
        label: label.slice(0, 500), model: state.model, cwd: state.cwd,
        status: state.status, elapsedMs: state.elapsedMs, cost: state.usage.cost.total,
        activity: state.activity.slice(-20), output: state.output.slice(-16384),
        error: state.error?.slice(-2000),
      }), { mode: 0o600 });
      renameSync(`${path}.tmp`, path);
    } catch {
      // A display failure must never cancel a delegate or lose its result.
      writable = false;
    }
  };
  try {
    update(details);
    const runtime = /^(node|bun)(\.exe)?$/i.test(basename(process.execPath)) ? process.execPath : "node";
    // Multiple shell-command arguments make tmux exec directly, without shell interpolation.
    pane = await withPaneGroup(target, command, async (group) => {
      let splitTarget = target;
      if (group.panes.length) {
        // Reconcile manually closed panes, then split the tallest surviving monitor.
        const live = (await command(["list-panes", "-t", target, "-F", "#{pane_id} #{pane_height}"]))
          .split("\n").map((line) => line.trim().split(/\s+/));
        group.panes = group.panes.filter((id) => live.some(([paneId]) => paneId === id));
        const monitors = live.filter(([id]) => group.panes.includes(id))
          .sort((a, b) => Number(b[1]) - Number(a[1]));
        if (monitors.length) splitTarget = monitors[0][0];
      }
      const id = (await command([
        "split-window", "-d", splitTarget === target ? "-h" : "-v", "-t", splitTarget, "-P", "-F", "#{pane_id}",
        runtime, fileURLToPath(new URL("monitor-view.mjs", import.meta.url)), path, String(process.pid),
      ])).trim();
      if (!/^%\d+$/.test(id)) throw new Error("tmux did not return a pane ID.");
      group.panes.push(id);
      try { await balanceMonitors(target, command, group); } catch { /* display-only, keep the child running */ }
      return id;
    });
    return {
      update,
      async close() {
        if (closed) return;
        closed = true;
        await withPaneGroup(target, command, async (group) => {
          try { await command(["kill-pane", "-t", pane!]); } catch { /* already closed */ }
          group.panes = group.panes.filter((id) => id !== pane);
          try { await balanceMonitors(target, command, group); } catch { /* display-only cleanup */ }
        });
        try { await rm(directory, { recursive: true, force: true }); } catch { /* best-effort display cleanup */ }
      },
    };
  } catch (error) {
    try { await rm(directory, { recursive: true, force: true }); } catch { /* preserve launch error */ }
    throw error;
  }
}
