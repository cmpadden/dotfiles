// Foreground subprocess lifecycle, adapted from Pi's MIT-licensed subagent example:
// https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent
import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { basename } from "node:path";
import type { Usage } from "@earendil-works/pi-ai";
import type { JsonAgentSessionEvent } from "@earendil-works/pi-coding-agent";

export const CHILD_INSTRUCTIONS = [
  "You are a delegated child working on one self-contained task.",
  "You do not have the parent's conversation. Follow the task and local repository instructions.",
  "Do not delegate, spawn another coding agent, or leave background work running.",
  "Return a concise report of findings, changes, validation, and unresolved issues.",
].join("\n");

export interface DelegateOptions {
  task: string;
  provider: string;
  model: string;
  thinking?: string;
  tools?: string[];
  cwd: string;
  trusted: boolean;
}

export interface DelegateDetails {
  model: string;
  status: "running" | "completed" | "failed" | "aborted";
  output: string;
  stderr: string;
  activity: string[];
  turns: number;
  usage: Usage;
  error?: string;
  exitCode?: number | null;
  exitSignal?: string | null;
  outputFile?: string;
}

export interface Invocation {
  command: string;
  args: string[];
}

// Reuse the running Pi version, including standalone builds, rather than a
// potentially different `pi` on PATH. Mirrors the upstream example.
export function piInvocation(): Invocation {
  const script = process.argv[1];
  if (script && !script.startsWith("/$bunfs/root/") && existsSync(script)) {
    return { command: process.execPath, args: [script] };
  }
  if (!/^(node|bun)(\.exe)?$/i.test(basename(process.execPath))) {
    return { command: process.execPath, args: [] };
  }
  return { command: "pi", args: [] };
}

export function childArguments(options: DelegateOptions): string[] {
  const args = [
    "--mode", "json", "--print", "--no-session",
    "--no-extensions", "--no-mcp", "--no-prompt-templates",
    options.trusted ? "--approve" : "--no-approve",
    "--provider", options.provider, "--model", options.model,
    "--tools", (options.tools ?? ["read", "bash", "edit", "write"]).join(","),
    "--append-system-prompt", CHILD_INSTRUCTIONS,
  ];
  if (options.thinking) args.push("--thinking", options.thinking);
  return args;
}

export async function runDelegate(
  options: DelegateOptions,
  signal?: AbortSignal,
  onUpdate?: (details: DelegateDetails) => void,
  invocation: Invocation = piInvocation(),
  killDelayMs = 5000,
): Promise<DelegateDetails> {
  const details: DelegateDetails = {
    model: `${options.provider}/${options.model}`,
    status: "running", output: "", stderr: "", activity: [], turns: 0,
    usage: {
      input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
    },
  };
  if (signal?.aborted) return { ...details, status: "aborted", error: "Delegation cancelled before launch." };

  return new Promise((resolve) => {
    // A dedicated POSIX process group lets cancellation reach child shell tools,
    // not just Pi itself. It is still piped, referenced, and awaited: never unref().
    const grouped = process.platform !== "win32";
    const proc = spawn(invocation.command, [...invocation.args, ...childArguments(options)], {
      cwd: options.cwd,
      shell: false,
      detached: grouped,
      stdio: ["pipe", "pipe", "pipe"],
      env: { ...process.env, PI_DELEGATE_CHILD: "1" },
    });
    let closed = false;
    let killTimer: ReturnType<typeof setTimeout> | undefined;
    let updateTimer: ReturnType<typeof setTimeout> | undefined;
    let buffer = "";
    let protocolError: string | undefined;
    let spawnError: string | undefined;
    let assistantSeen = false;
    let stopReason: string | undefined;
    let assistantError: string | undefined;

    const emit = () => {
      // Snapshots must not mutate already emitted tool results/session entries.
      try {
        onUpdate?.({ ...details, activity: [...details.activity], usage: { ...details.usage, cost: { ...details.usage.cost } } });
      } catch (error) {
        spawnError = `Could not publish child progress: ${String(error)}`;
        terminate();
      }
    };
    const scheduleUpdate = () => {
      if (!closed && !updateTimer) updateTimer = setTimeout(() => { updateTimer = undefined; emit(); }, 100);
    };
    const activity = (text: string) => {
      details.activity.push(text.slice(0, 500));
      details.activity = details.activity.slice(-20);
      scheduleUpdate();
    };
    const kill = (sig: NodeJS.Signals) => {
      if (!proc.pid) return;
      try {
        if (grouped) process.kill(-proc.pid, sig);
        else proc.kill(sig);
      } catch (error) {
        if ((error as NodeJS.ErrnoException).code !== "ESRCH") {
          details.stderr = `${details.stderr}\nUnable to send ${sig}: ${String(error)}`.slice(-65536);
        }
      }
    };
    const terminate = () => {
      if (closed || killTimer) return;
      kill("SIGTERM");
      // proc.killed only means a signal was sent, not that the process exited.
      killTimer = setTimeout(() => kill("SIGKILL"), killDelayMs);
    };
    const abort = () => { details.status = "aborted"; terminate(); };

    const processLine = (line: string) => {
      if (!line.trim() || protocolError) return;
      if (Buffer.byteLength(line) > 8 * 1024 * 1024) {
        protocolError = "Child JSONL record exceeded 8 MiB.";
        terminate();
        return;
      }
      let event: JsonAgentSessionEvent;
      try {
        const parsed = JSON.parse(line);
        if (!parsed || typeof parsed.type !== "string") throw new Error("Missing event type");
        event = parsed;
      } catch {
        protocolError = "Child emitted invalid JSONL output.";
        terminate();
        return;
      }
      try {
        switch (event.type) {
        case "message_start":
          if (event.message.role === "assistant") details.output = "";
          break;
        case "message_update": {
          const delta = event.assistantMessageEvent;
          if (delta.type === "text_delta") {
            details.output = (details.output + delta.delta).slice(-16384);
            scheduleUpdate();
          }
          break;
        }
        case "message_end": {
          const message = event.message;
          if (message.role !== "assistant") break;
          assistantSeen = true;
          details.turns++;
          stopReason = message.stopReason;
          assistantError = message.errorMessage;
          details.output = message.content.filter((part) => part.type === "text").map((part) => part.text).join("\n");
          for (const key of ["input", "output", "cacheRead", "cacheWrite", "totalTokens"] as const) {
            details.usage[key] += message.usage?.[key] ?? 0;
          }
          for (const key of ["input", "output", "cacheRead", "cacheWrite", "total"] as const) {
            details.usage.cost[key] += message.usage?.cost?.[key] ?? 0;
          }
          scheduleUpdate();
          break;
        }
        case "tool_execution_start": {
          const args = event.args as Record<string, unknown>;
          const target = args?.command ?? args?.path ?? args?.pattern ?? "";
          activity(`→ ${event.toolName} ${String(target)}`);
          break;
        }
        case "tool_execution_end":
          activity(`${event.isError ? "✗" : "✓"} ${event.toolName}`);
          break;
        case "auto_retry_start":
          activity(`Retry ${event.attempt}: ${event.errorMessage}`);
          break;
        }
      } catch (error) {
        protocolError = `Invalid child event: ${String(error)}`;
        terminate();
      }
    };

    proc.stdout.setEncoding("utf8");
    proc.stdout.on("data", (chunk: string) => {
      buffer += chunk;
      let newline: number;
      while ((newline = buffer.indexOf("\n")) !== -1) {
        const line = buffer.slice(0, newline);
        buffer = buffer.slice(newline + 1);
        processLine(line);
      }
      if (Buffer.byteLength(buffer) > 8 * 1024 * 1024) {
        protocolError = "Child JSONL record exceeded 8 MiB.";
        buffer = "";
        terminate();
      }
    });
    proc.stderr.setEncoding("utf8");
    proc.stderr.on("data", (chunk: string) => { details.stderr = (details.stderr + chunk).slice(-65536); });
    proc.stdin.on("error", (error: NodeJS.ErrnoException) => {
      // An early CLI failure may close stdin before accepting the task.
      if (error.code !== "EPIPE") { spawnError = `Child stdin failed: ${error.message}`; terminate(); }
    });
    proc.on("error", (error) => { spawnError = `Could not start Pi: ${error.message}`; });
    proc.on("close", (code, exitSignal) => {
      closed = true;
      signal?.removeEventListener("abort", abort);
      if (killTimer) clearTimeout(killTimer);
      if (updateTimer) clearTimeout(updateTimer);
      if (buffer.trim()) processLine(buffer);
      details.exitCode = code;
      details.exitSignal = exitSignal;
      if (details.status === "aborted") {
        details.error = "Delegation cancelled.";
      } else {
        const failure = spawnError ?? protocolError
          ?? (code !== 0 ? `Child exited ${exitSignal ? `with signal ${exitSignal}` : `with code ${code}`}.` : undefined)
          ?? (assistantSeen && stopReason !== "stop" ? assistantError || `Child ended with ${stopReason ?? "no stop reason"}.` : undefined)
          ?? (!assistantSeen || !details.output.trim() ? "Child exited without a final text response." : undefined);
        details.status = failure ? "failed" : "completed";
        details.error = failure;
      }
      resolve(details);
    });

    signal?.addEventListener("abort", abort, { once: true });
    if (signal?.aborted) abort();
    emit();
    // stdin avoids shell quoting, argument-size limits, @file interpretation,
    // and exposing the delegated task in the process argument list.
    proc.stdin.end(`Task: ${options.task}`);
  });
}
