import { mkdtemp, realpath, stat, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { truncateHead, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Container, Text, truncateToWidth } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { DelegateQueue } from "./queue.ts";
import { openMonitor, type DelegateMonitor } from "./monitor.ts";
import { initialDetails, runDelegate, type DelegateDetails, type DelegateOptions } from "./runtime.ts";

const MAX_CONCURRENT_CHILDREN = 3;
const QUEUE_HEARTBEAT_MS = 1000;
const BUILTIN_TOOLS = ["read", "bash", "edit", "write", "grep", "find", "ls"];
const THINKING_LEVELS = ["off", "minimal", "low", "medium", "high", "xhigh", "max"];

const STATUS_COLORS = {
  queued: "warning",
  running: "muted",
  completed: "success",
  failed: "error",
  aborted: "error",
} as const;

const unwrap = (text: string) => text.trim().replace(/\n/g, " ");

const DELEGATE_DESCRIPTION = unwrap(`
Run a self-contained task in a fresh Pi child using an exact provider/model ID.
Waits for completion and streams progress; no polling or background jobs.
Up to three children run concurrently per session; additional calls queue and remain awaited.
cwd selects an existing directory (default: parent cwd);
no worktrees are created or removed automatically.
The child shares credentials, NOT the conversation; include all necessary context.
Child extensions and MCP are disabled. This is not a sandbox.
Default tools: read,bash,edit,write. For read-only planning use read,grep,find,ls.
Output is capped at 50 KiB/2,000 lines; longer output is saved to a temporary file.
`);

const DELEGATE_PROMPT_GUIDELINES = `
Give delegate a self-contained task, explicit edit permissions, and expected output;
children cannot see this conversation.

Give every delegate call a short label derived from its task (action + specific targets,
e.g. "Rebase PRs #6182–6184"). Omit shared context, constraints, and boilerplate from the label.

Before using delegate, decide whether the task needs isolation.
For independent write tasks, use wt to prepare separate worktrees first,
then pass each path as cwd.
Never reuse a worktree being used by another agent or the user.

For read-only delegate investigations, prefer tools read,grep,find,ls without a new worktree.
If isolation is uncertain, investigate read-only first. Bash and builds/tests may write files.

Avoid delegating trivial work unless the user explicitly requests delegation,
including for testing.

Do not run delegate concurrently with parent or sibling writes/branch changes
in the same checkout. cwd is not a sandbox;
different subdirectories are not separate worktrees. Verify child findings before acting.

When preparing delegate worktrees with wt, choose an explicit base;
uncommitted changes are not copied. Do not silently approve hooks,
assume background setup is finished, or automatically remove worktrees containing useful work.
`.split("\n\n").map(unwrap);

const DELEGATE_PARAMETERS = Type.Object({
  label: Type.Optional(Type.String({
    minLength: 1,
    maxLength: 80,
    description: "Short display label derived from the task: action + specific targets, e.g. Rebase PRs #6182–6184. No boilerplate.",
  })),
  task: Type.String({
    minLength: 1,
    description: "Self-contained task, context, constraints, and expected output",
  }),
  model: Type.String({
    minLength: 3,
    description: "Exact provider/model ID; model IDs may contain slashes",
  }),
  cwd: Type.Optional(Type.String({
    minLength: 1,
    description: unwrap(`
Existing working directory, absolute or relative to parent cwd; defaults to parent cwd.
Prepare independent write worktrees with wt first.
`),
  })),
  thinking: Type.Optional(Type.String({ enum: THINKING_LEVELS })),
  tools: Type.Optional(Type.Array(Type.String({ enum: BUILTIN_TOOLS }), {
    minItems: 1,
    uniqueItems: true,
    description: "Built-in tool allowlist; omit for read,bash,edit,write",
  })),
});

function parseModelId(id: string): { provider: string; model: string } {
  const slash = id.indexOf("/");
  if (slash < 1 || slash === id.length - 1) throw new Error("Use an exact provider/model ID.");
  return { provider: id.slice(0, slash), model: id.slice(slash + 1) };
}

function resolvePath(path: string, base: string): string {
  if (path.startsWith("@")) path = path.slice(1);
  if (path === "~" || path.startsWith("~/")) path = join(homedir(), path.slice(1));
  return resolve(base, path);
}

async function resolveDirectory(path: string, base: string): Promise<string> {
  const directory = await realpath(resolvePath(path, base));
  if (!(await stat(directory)).isDirectory()) {
    throw new Error("Delegate cwd must be an existing directory.");
  }
  return directory;
}

async function toToolResult(details: DelegateDetails) {
  const failed = details.status !== "completed";
  const full = [details.error, details.output, failed && details.stderr]
    .filter(Boolean)
    .join("\n\n");
  const { content, truncated } = truncateHead(full);
  let text = content;
  if (truncated) {
    details.outputFile = join(await mkdtemp(join(tmpdir(), "pi-delegate-")), "output.txt");
    await writeFile(details.outputFile, full, { mode: 0o600 });
    text += `\n\n[Output truncated. Full output: ${details.outputFile}]`;
  }
  return {
    content: [{ type: "text" as const, text: text || "(no output)" }],
    details,
    usage: details.usage,
    isError: failed,
  };
}

const seconds = (ms?: number) => `${Math.floor((ms ?? 0) / 1000)}s`;

export default function (pi: ExtensionAPI) {
  // Defense in depth if this extension is explicitly loaded by a child.
  if (process.env.PI_DELEGATE_CHILD === "1") return;

  const active = new Map<AbortController, Promise<DelegateDetails>>();
  const queue = new DelegateQueue(MAX_CONCURRENT_CHILDREN);
  let closing = false;

  pi.on("session_shutdown", async () => {
    closing = true;
    for (const controller of active.keys()) controller.abort();
    await Promise.allSettled(active.values());
  });

  pi.registerTool({
    name: "delegate",
    label: "Delegate",
    executionMode: "parallel",
    description: DELEGATE_DESCRIPTION,
    promptSnippet: "Delegate a bounded task to a chosen model and await its result",
    promptGuidelines: DELEGATE_PROMPT_GUIDELINES,
    parameters: DELEGATE_PARAMETERS,

    async execute(_id, params, signal, onUpdate, ctx) {
      if (closing) throw new Error("Delegate is shutting down.");
      if (!params.task.trim()) throw new Error("Delegated task must not be blank.");
      if (params.cwd !== undefined && !params.cwd.trim()) {
        throw new Error("Delegate cwd must not be blank.");
      }
      const { provider, model } = parseModelId(params.model);
      if (!ctx.modelRegistry.find(provider, model)) {
        throw new Error(`Unknown model: ${params.model}. Use pi --list-models to find exact IDs.`);
      }

      const settings = pi.getSettings() as Record<string, unknown>;
      const config = settings["pi-delegate"];
      const display = config !== null && typeof config === "object"
        && !Array.isArray(config) && (config as { display?: unknown }).display === "tmux"
        ? "tmux" : "hidden";

      const queuedAt = Date.now();
      const controller = new AbortController();
      const childSignal = signal ? AbortSignal.any([signal, controller.signal]) : controller.signal;

      const publish = (details: DelegateDetails) => {
        const placeholder = details.status === "queued"
          ? "Queued (three-child session limit)…"
          : "Working…";
        onUpdate?.({
          content: [{ type: "text", text: truncateHead(details.output || placeholder).content }],
          details,
        });
      };

      const run = (async () => {
        const cwd = await resolveDirectory(params.cwd ?? ctx.cwd, ctx.cwd);
        const options: DelegateOptions = {
          task: params.task,
          provider,
          model,
          tools: params.tools,
          thinking: params.thinking ?? ctx.thinkingLevel,
          cwd,
          // A trusted parent must not silently approve a different project/path.
          trusted: cwd === await realpath(ctx.cwd) && ctx.isProjectTrusted(),
          queuedAt,
        };

        const queued = initialDetails(options);
        const publishQueued = () => publish({ ...queued, queuedMs: Date.now() - queuedAt });
        publishQueued();
        const heartbeat = setInterval(() => {
          try { publishQueued(); } catch { controller.abort(); }
        }, QUEUE_HEARTBEAT_MS);

        let release: (() => void) | undefined;
        try {
          release = await queue.acquire(childSignal);
        } finally {
          clearInterval(heartbeat);
        }
        if (!release) {
          return {
            ...queued,
            status: "aborted" as const,
            queuedMs: Date.now() - queuedAt,
            error: "Delegation cancelled before launch.",
          };
        }
        let monitor: DelegateMonitor | undefined;
        try {
          if (display === "tmux" && !childSignal.aborted) {
            try {
              monitor = await openMonitor(params.label || params.task, queued);
            } catch {
              if (ctx.hasUI) ctx.ui.notify("Delegate tmux monitor unavailable; continuing hidden.", "warning");
            }
          }
          return await runDelegate(options, childSignal, (details) => {
            monitor?.update(details);
            publish(details);
          });
        } finally {
          try { await monitor?.close(); } finally { release(); }
        }
      })();

      active.set(controller, run);
      try {
        return await toToolResult(await run);
      } finally {
        active.delete(controller);
      }
    },

    renderCall(args, theme, context) {
      // The call slot is composed before the result slot. Read shared details at
      // render time so each progress update appears in the same compact header.
      return {
        render(width: number) {
          const details = context.state.details as DelegateDetails | undefined;
          const model = context.expanded ? args.model : args.model?.split("/").pop();
          let title = theme.fg("toolTitle", theme.bold("delegate ")) + theme.fg("accent", model ?? "…");
          if (details) {
            const ms = details.status === "queued" ? details.queuedMs : details.elapsedMs;
            title += theme.fg(STATUS_COLORS[details.status] ?? "error", ` · ${details.status} ${seconds(ms)}`);
            title += theme.fg("dim", ` · $${details.usage.cost.total.toFixed(2)}`);
          } else if (context.isError) {
            title += theme.fg("error", " · failed");
          }
          const task = args.task ?? "…";
          const label = args.label?.replace(/\s+/g, " ").trim() || task.replace(/\s+/g, " ").trim();
          const lines = context.expanded
            ? [title, ...(args.label ? [theme.fg("dim", label)] : []), theme.fg("dim", task)]
            : [title, theme.fg("dim", label)];
          return context.expanded
            ? new Text(lines.join("\n"), 0, 0).render(width)
            : lines.map((line) => truncateToWidth(line, width));
        },
        invalidate() {},
      };
    },

    renderResult(result, { expanded }, theme, context) {
      context.state.details = result.details;
      if (!expanded) return new Container();
      const details = result.details as DelegateDetails | undefined;
      const content = result.content
        .filter((part) => part.type === "text")
        .map((part) => part.text)
        .join("\n");
      if (!details) return new Text(content, 0, 0);

      const { status, usage } = details;
      const timing = `${seconds(details.elapsedMs)} elapsed · ${seconds(details.queuedMs)} queued`;
      const cost = `$${usage.cost.total.toFixed(4)}`;
      const activity = details.activity.join("\n");
      return new Text([
        theme.fg(STATUS_COLORS[status] ?? "error", `${status} · ${timing}`),
        details.cwd && theme.fg("muted", `cwd: ${details.cwd}`),
        theme.fg("dim", `${details.turns} turns · ↑${usage.input} ↓${usage.output} · ${cost}`),
        activity && theme.fg("muted", activity),
        content,
      ].filter(Boolean).join("\n"), 0, 0);
    },
  });
}
