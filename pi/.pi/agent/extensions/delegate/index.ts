import { mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { truncateHead, type ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { runDelegate, type DelegateDetails } from "./runtime.ts";

const builtinTools = ["read", "bash", "edit", "write", "grep", "find", "ls"] as const;

export default function (pi: ExtensionAPI) {
  // Defense in depth if this extension is explicitly loaded by a child.
  if (process.env.PI_DELEGATE_CHILD === "1") return;

  const active = new Map<AbortController, Promise<DelegateDetails>>();
  pi.on("session_shutdown", async () => {
    for (const controller of active.keys()) controller.abort();
    await Promise.allSettled(active.values());
  });

  pi.registerTool({
    name: "delegate",
    label: "Delegate",
    executionMode: "sequential",
    description: [
      "Run a self-contained task in a fresh Pi child using an exact provider/model ID.",
      "Waits for completion and streams progress; no polling or background jobs.",
      "The child shares this checkout and credentials, NOT the conversation; include all necessary context.",
      "Child extensions and MCP are disabled. This is not a sandbox.",
      "Default tools: read,bash,edit,write. For read-only planning use read,grep,find,ls.",
      "Output is capped at 50 KiB/2,000 lines; longer output is saved to a temporary file.",
    ].join(" "),
    promptSnippet: "Delegate a bounded task to a chosen model and await its result",
    promptGuidelines: [
      "Give delegate a self-contained task, explicit edit permissions, and expected output; children cannot see this conversation.",
      "Do not delegate trivial work or use delegate concurrently with edits to the same files. Verify child findings before acting.",
    ],
    parameters: Type.Object({
      task: Type.String({ minLength: 1, description: "Self-contained task, context, constraints, and expected output" }),
      model: Type.String({ minLength: 3, description: "Exact provider/model ID; model IDs may contain slashes" }),
      thinking: Type.Optional(Type.String({ enum: ["off", "minimal", "low", "medium", "high", "xhigh", "max"] })),
      tools: Type.Optional(Type.Array(Type.String({ enum: [...builtinTools] }), {
        minItems: 1, uniqueItems: true, description: "Built-in tool allowlist; omit for read,bash,edit,write",
      })),
    }),
    async execute(_id, params, signal, onUpdate, ctx) {
      if (!params.task.trim()) throw new Error("Delegated task must not be blank.");
      const slash = params.model.indexOf("/");
      if (slash < 1 || slash === params.model.length - 1) throw new Error("Use an exact provider/model ID.");
      const provider = params.model.slice(0, slash);
      const model = params.model.slice(slash + 1);
      if (!ctx.modelRegistry.find(provider, model)) throw new Error(`Unknown model: ${params.model}. Use pi --list-models to find exact IDs.`);

      const controller = new AbortController();
      const childSignal = signal ? AbortSignal.any([signal, controller.signal]) : controller.signal;
      const run = runDelegate({
        task: params.task, provider, model, tools: params.tools,
        thinking: params.thinking ?? ctx.thinkingLevel,
        cwd: ctx.cwd, trusted: ctx.isProjectTrusted(),
      }, childSignal, (details) => {
        onUpdate?.({
          content: [{ type: "text", text: truncateHead(details.output || "Working…").content }],
          details,
        });
      });
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
    renderCall(args, theme) {
      const model = args.model ?? "…";
      const task = args.task?.replace(/\s+/g, " ").slice(0, 140) ?? "…";
      return new Text(`${theme.fg("toolTitle", theme.bold("delegate "))}${theme.fg("accent", model)}\n${theme.fg("dim", task)}`, 0, 0);
    },
    renderResult(result, { expanded, isPartial }, theme) {
      const details = result.details as DelegateDetails | undefined;
      const content = result.content.filter((part) => part.type === "text").map((part) => part.text).join("\n");
      if (!details) return new Text(content, 0, 0);
      const status = isPartial ? "running" : details.status;
      const color = status === "completed" ? "success" : status === "running" ? "muted" : "error";
      const usage = `${details.turns} turns · ↑${details.usage.input} ↓${details.usage.output} · $${details.usage.cost.total.toFixed(4)}`;
      const activity = (expanded ? details.activity : details.activity.slice(-3)).join("\n");
      const preview = expanded ? content : content.split("\n").slice(-6).join("\n").slice(-1500);
      return new Text([
        theme.fg(color, status), theme.fg("dim", usage),
        activity && theme.fg("muted", activity), preview,
      ].filter(Boolean).join("\n"), 0, 0);
    },
  });
}
