import { mkdtemp, realpath, stat, writeFile } from "node:fs/promises";
import { homedir, tmpdir } from "node:os";
import { join, resolve } from "node:path";
import { truncateHead, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { initialDetails, runDelegate, type DelegateDetails, type DelegateOptions } from "./runtime.ts";
import { DelegateQueue } from "./queue.ts";

const builtinTools = ["read", "bash", "edit", "write", "grep", "find", "ls"] as const;

export default function (pi: ExtensionAPI) {
  // Defense in depth if this extension is explicitly loaded by a child.
  if (process.env.PI_DELEGATE_CHILD === "1") return;

  const active = new Map<AbortController, Promise<DelegateDetails>>();
  const queue = new DelegateQueue(3);
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
    description: [
      "Run a self-contained task in a fresh Pi child using an exact provider/model ID.",
      "Waits for completion and streams progress; no polling or background jobs.",
      "Up to three children run concurrently per session; additional calls queue and remain awaited.",
      "cwd selects an existing directory (default: parent cwd); no worktrees are created or removed automatically.",
      "The child shares credentials, NOT the conversation; include all necessary context.",
      "Child extensions and MCP are disabled. This is not a sandbox.",
      "Default tools: read,bash,edit,write. For read-only planning use read,grep,find,ls.",
      "Output is capped at 50 KiB/2,000 lines; longer output is saved to a temporary file.",
    ].join(" "),
    promptSnippet: "Delegate a bounded task to a chosen model and await its result",
    promptGuidelines: [
      "Give delegate a self-contained task, explicit edit permissions, and expected output; children cannot see this conversation.",
      "Before using delegate, decide whether the task needs isolation. For independent write tasks, use wt to prepare separate worktrees first, then pass each path as cwd. Never reuse a worktree being used by another agent or the user.",
      "For read-only delegate investigations, prefer tools read,grep,find,ls without a new worktree. If isolation is uncertain, investigate read-only first. Bash and builds/tests may write files.",
      "Do not delegate trivial work or run delegate concurrently with parent or sibling writes/branch changes in the same checkout. cwd is not a sandbox; different subdirectories are not separate worktrees. Verify child findings before acting.",
      "When preparing delegate worktrees with wt, choose an explicit base; uncommitted changes are not copied. Do not silently approve hooks, assume background setup is finished, or automatically remove worktrees containing useful work.",
    ],
    parameters: Type.Object({
      task: Type.String({ minLength: 1, description: "Self-contained task, context, constraints, and expected output" }),
      model: Type.String({ minLength: 3, description: "Exact provider/model ID; model IDs may contain slashes" }),
      cwd: Type.Optional(Type.String({ minLength: 1, description: "Existing working directory, absolute or relative to parent cwd; defaults to parent cwd. Prepare independent write worktrees with wt first." })),
      thinking: Type.Optional(Type.String({ enum: ["off", "minimal", "low", "medium", "high", "xhigh", "max"] })),
      tools: Type.Optional(Type.Array(Type.String({ enum: [...builtinTools] }), {
        minItems: 1, uniqueItems: true, description: "Built-in tool allowlist; omit for read,bash,edit,write",
      })),
    }),
    async execute(_id, params, signal, onUpdate, ctx) {
      if (closing) throw new Error("Delegate is shutting down.");
      if (!params.task.trim()) throw new Error("Delegated task must not be blank.");
      if (params.cwd !== undefined && !params.cwd.trim()) throw new Error("Delegate cwd must not be blank.");
      const slash = params.model.indexOf("/");
      if (slash < 1 || slash === params.model.length - 1) throw new Error("Use an exact provider/model ID.");
      const provider = params.model.slice(0, slash);
      const model = params.model.slice(slash + 1);
      if (!ctx.modelRegistry.find(provider, model)) throw new Error(`Unknown model: ${params.model}. Use pi --list-models to find exact IDs.`);

      const controller = new AbortController();
      const childSignal = signal ? AbortSignal.any([signal, controller.signal]) : controller.signal;
      let path = params.cwd ?? ctx.cwd;
      if (path.startsWith("@")) path = path.slice(1);
      if (path === "~" || path.startsWith("~/")) path = join(homedir(), path.slice(1));
      const options: DelegateOptions = {
        task: params.task, provider, model, tools: params.tools,
        thinking: params.thinking ?? ctx.thinkingLevel,
        cwd: resolve(ctx.cwd, path), trusted: false, queuedAt: Date.now(),
      };
      const publish = (details: DelegateDetails) => {
        onUpdate?.({
          content: [{ type: "text", text: truncateHead(details.output || (details.status === "queued" ? "Queued (three-child session limit)…" : "Working…")).content }],
          details,
        });
      };
      const run = (async () => {
        options.cwd = await realpath(options.cwd);
        if (!(await stat(options.cwd)).isDirectory()) throw new Error("Delegate cwd must be an existing directory.");
        // A trusted parent must not silently approve a different project/path.
        options.trusted = options.cwd === await realpath(ctx.cwd) && ctx.isProjectTrusted();
        const queued = initialDetails(options);
        const updateQueue = () => {
          queued.queuedMs = Date.now() - options.queuedAt!;
          publish({ ...queued });
        };
        let timer: ReturnType<typeof setInterval> | undefined;
        let release: (() => void) | undefined;
        try {
          updateQueue();
          timer = setInterval(() => {
            try { updateQueue(); } catch { controller.abort(); }
          }, 1000);
          release = await queue.acquire(childSignal);
          clearInterval(timer);
          if (!release || childSignal.aborted) {
            return { ...queued, status: "aborted" as const, queuedMs: Date.now() - options.queuedAt!, error: "Delegation cancelled before launch." };
          }
          return await runDelegate(options, childSignal, publish);
        } finally {
          if (timer) clearInterval(timer);
          release?.();
        }
      })();
      active.set(controller, run);
      try {
        const details = await run;
        const text = [details.error, details.output, details.status !== "completed" ? details.stderr : ""].filter(Boolean).join("\n\n");
        const truncated = truncateHead(text);
        let output = truncated.content;
        if (truncated.truncated) {
          const directory = await mkdtemp(join(tmpdir(), "pi-delegate-"));
          details.outputFile = join(directory, "output.txt");
          await writeFile(details.outputFile, text, { mode: 0o600 });
          output += `\n\n[Output truncated. Full output: ${details.outputFile}]`;
        }
        return {
          content: [{ type: "text" as const, text: output || "(no output)" }],
          details,
          usage: details.usage,
          isError: details.status !== "completed",
        };
      } finally {
        active.delete(controller);
      }
    },
    renderCall(args, theme, context) {
      const model = args.model ?? "…";
      const task = args.task?.replace(/\s+/g, " ").slice(0, 140) ?? "…";
      const cwd = args.cwd ?? context.cwd;
      return new Text(`${theme.fg("toolTitle", theme.bold("delegate "))}${theme.fg("accent", model)}\n${theme.fg("dim", task)}\n${theme.fg("muted", `cwd: ${cwd}`)}`, 0, 0);
    },
    renderResult(result, { expanded }, theme) {
      const details = result.details as DelegateDetails | undefined;
      const content = result.content.filter((part) => part.type === "text").map((part) => part.text).join("\n");
      if (!details) return new Text(content, 0, 0);
      const status = details.status;
      const color = status === "completed" ? "success" : status === "queued" ? "warning" : status === "running" ? "muted" : "error";
      const timing = `${Math.floor((details.elapsedMs ?? 0) / 1000)}s elapsed · ${Math.floor((details.queuedMs ?? 0) / 1000)}s queued`;
      const usage = `${details.turns} turns · ↑${details.usage.input} ↓${details.usage.output} · $${details.usage.cost.total.toFixed(4)}`;
      const activity = (expanded ? details.activity : details.activity.slice(-3)).join("\n");
      const preview = expanded ? content : content.split("\n").slice(-6).join("\n").slice(-1500);
      return new Text([
        theme.fg(color, `${status} · ${timing}`),
        details.cwd && theme.fg("muted", `cwd: ${details.cwd}`), theme.fg("dim", usage),
        activity && theme.fg("muted", activity), preview,
      ].filter(Boolean).join("\n"), 0, 0);
    },
  });
}
