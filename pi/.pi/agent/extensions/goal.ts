import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

type GoalCheckpoint = {
  note: string;
  timestamp: number;
};

type GoalState = {
  active: boolean;
  text?: string;
  startedAt?: number;
  completedAt?: number;
  checkpoints: GoalCheckpoint[];
};

const ENTRY_TYPE = "goal-state";

const emptyState = (): GoalState => ({
  active: false,
  text: undefined,
  startedAt: undefined,
  completedAt: undefined,
  checkpoints: [],
});

export default function (pi: ExtensionAPI) {
  let state: GoalState = emptyState();

  function persist(): void {
    pi.appendEntry(ENTRY_TYPE, state);
  }

  function restore(ctx: ExtensionContext): void {
    state = emptyState();

    const latest = ctx.sessionManager
      .getBranch()
      .filter((entry): entry is { type: "custom"; customType: string; data?: GoalState } => {
        return entry.type === "custom" && entry.customType === ENTRY_TYPE;
      })
      .pop();

    if (latest?.data) {
      state = {
        active: latest.data.active ?? false,
        text: latest.data.text,
        startedAt: latest.data.startedAt,
        completedAt: latest.data.completedAt,
        checkpoints: latest.data.checkpoints ?? [],
      };
    }
  }

  function updateUI(ctx: ExtensionContext): void {
    if (!ctx.hasUI) return;

    if (!state.active || !state.text) {
      ctx.ui.setStatus("goal", undefined);
      ctx.ui.setWidget("goal", undefined);
      return;
    }

    const goalText = state.text.length > 60 ? `${state.text.slice(0, 57)}...` : state.text;
    ctx.ui.setStatus("goal", ctx.ui.theme.fg("accent", `🎯 ${goalText}`));

    const lines = [
      ctx.ui.theme.fg("accent", ctx.ui.theme.bold("Current Goal")),
      state.text,
    ];

    const lastCheckpoint = state.checkpoints[state.checkpoints.length - 1];
    if (lastCheckpoint) {
      lines.push("");
      lines.push(ctx.ui.theme.fg("muted", "Latest checkpoint"));
      lines.push(lastCheckpoint.note);
    }

    ctx.ui.setWidget("goal", lines);
  }

  function setGoal(text: string, ctx: ExtensionContext): void {
    state = {
      active: true,
      text,
      startedAt: Date.now(),
      completedAt: undefined,
      checkpoints: [],
    };
    persist();
    updateUI(ctx);
    ctx.ui.notify(`Goal set: ${text}`, "info");
  }

  function clearGoal(ctx: ExtensionContext, reason: "cleared" | "done"): void {
    const previous = state.text;
    state = {
      ...state,
      active: false,
      completedAt: Date.now(),
    };
    persist();
    updateUI(ctx);
    ctx.ui.notify(reason === "done" ? `Goal completed: ${previous ?? "goal"}` : "Goal cleared", "info");
  }

  pi.registerCommand("goal", {
    description: "Manage a long-running goal (/goal set|checkpoint|done|clear|status)",
    handler: async (args, ctx) => {
      const trimmed = args.trim();
      const [subcommand, ...rest] = trimmed.split(/\s+/);
      const remainder = rest.join(" ").trim();

      if (!trimmed || subcommand === "status") {
        if (!state.active || !state.text) {
          ctx.ui.notify("No active goal", "info");
          return;
        }

        const checkpointText = state.checkpoints.length
          ? `\nLatest checkpoint: ${state.checkpoints[state.checkpoints.length - 1].note}`
          : "";
        ctx.ui.notify(`Current goal: ${state.text}${checkpointText}`, "info");
        return;
      }

      if (subcommand === "set") {
        if (!remainder) {
          ctx.ui.notify("Usage: /goal set <goal>", "warning");
          return;
        }
        setGoal(remainder, ctx);
        return;
      }

      if (subcommand === "checkpoint") {
        if (!state.active || !state.text) {
          ctx.ui.notify("No active goal", "warning");
          return;
        }
        const note = remainder || "Progress updated";
        state = {
          ...state,
          checkpoints: [...state.checkpoints, { note, timestamp: Date.now() }],
        };
        persist();
        updateUI(ctx);
        ctx.ui.notify(`Checkpoint saved: ${note}`, "info");
        return;
      }

      if (subcommand === "done") {
        if (!state.active) {
          ctx.ui.notify("No active goal", "warning");
          return;
        }
        clearGoal(ctx, "done");
        return;
      }

      if (subcommand === "clear") {
        if (!state.active) {
          ctx.ui.notify("No active goal", "warning");
          return;
        }
        clearGoal(ctx, "cleared");
        return;
      }

      // Convenience: /goal <text>
      setGoal(trimmed, ctx);
    },
  });

  pi.on("before_agent_start", async () => {
    if (!state.active || !state.text) return;

    const lastCheckpoint = state.checkpoints[state.checkpoints.length - 1];
    const checkpointLine = lastCheckpoint ? `\nLatest checkpoint: ${lastCheckpoint.note}` : "";

    return {
      message: {
        customType: "goal-context",
        content: `[ACTIVE GOAL]\nCurrent goal: ${state.text}${checkpointLine}\nPrioritize work toward this goal until it is completed or replaced.`,
        display: false,
      },
    };
  });

  pi.on("session_start", async (_event, ctx) => {
    restore(ctx);
    updateUI(ctx);
  });

  pi.on("session_tree", async (_event, ctx) => {
    restore(ctx);
    updateUI(ctx);
  });
}
