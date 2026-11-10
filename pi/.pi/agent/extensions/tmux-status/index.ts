import { randomUUID } from "node:crypto";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { PaneStatus } from "./runtime.ts";

export default function (pi: ExtensionAPI) {
  const pane = process.env.TMUX_PANE;
  if (!process.env.TMUX || !pane || !/^%\d+$/.test(pane)) return;

  let status: PaneStatus | undefined;
  let working = false;
  let waiting = false;
  let compacting = false;
  let finished = false;

  const update = () => status?.update(
    waiting ? "waiting" : working || compacting ? "working" : finished ? "done" : "idle",
  );

  pi.on("session_start", async (_event, ctx) => {
    // Print/JSON/RPC children inherit TMUX_PANE but do not own its terminal.
    // In particular, a delegated child must not replace its parent's state.
    if (ctx.mode !== "tui") return;
    working = !ctx.isIdle();
    waiting = false;
    compacting = false;
    finished = false;
    status = new PaneStatus(
      (args) => pi.exec("tmux", args, { timeout: 1_000, maxBuffer: 16_384 }),
      pane,
      randomUUID(),
    );
    await status.start(working ? "working" : "idle");
  });

  const start = () => {
    working = true;
    finished = false;
    return update();
  };
  pi.on("before_agent_start", start);
  pi.on("agent_start", start);
  // agent_end is not final: retries, compaction, and queued prompts may follow.
  pi.on("agent_settled", (event) => {
    working = false;
    finished = !event.aborted;
    return update();
  });

  pi.on("ui_prompt_start", () => {
    waiting = true;
    return update();
  });
  pi.on("ui_prompt_end", () => {
    waiting = false;
    return update();
  });

  pi.on("session_before_compact", () => {
    compacting = true;
    return update();
  });
  const endCompaction = () => {
    compacting = false;
    return update();
  };
  pi.on("session_compact", endCompaction);
  pi.on("session_compact_failed", endCompaction);

  pi.on("session_shutdown", async () => {
    await status?.stop();
    status = undefined;
  });
}
