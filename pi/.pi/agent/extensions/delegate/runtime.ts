// Foreground subprocess lifecycle, adapted from Pi's MIT-licensed subagent example:
// https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent
import { spawn } from "node:child_process";
import { existsSync } from "node:fs";
import { basename } from "node:path";
import type { Usage } from "@earendil-works/pi-ai";
import type { JsonAgentSessionEvent } from "@earendil-works/pi-coding-agent";

const DEFAULT_TOOLS = ["read", "bash", "edit", "write"];
const MAX_RECORD_BYTES = 8 * 1024 * 1024;
const MAX_STDERR_CHARS = 65536;
const MAX_STREAMED_OUTPUT_CHARS = 16384;
const MAX_ACTIVITY_ENTRIES = 20;
const MAX_ACTIVITY_CHARS = 500;
const UPDATE_THROTTLE_MS = 100;
const HEARTBEAT_MS = 1000;
const RECORD_TOO_LARGE = "Child JSONL record exceeded 8 MiB.";

const USAGE_KEYS = ["input", "output", "cacheRead", "cacheWrite", "totalTokens"] as const;
const COST_KEYS = ["input", "output", "cacheRead", "cacheWrite", "total"] as const;

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
  queuedAt?: number;
}

export interface DelegateDetails {
  model: string;
  status: "queued" | "running" | "completed" | "failed" | "aborted";
  cwd: string;
  queuedMs: number;
  elapsedMs: number;
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

interface Outcome {
  assistantSeen: boolean;
  stopReason?: string;
  assistantError?: string;
}

// Reuse the running Pi (including standalone builds), not whichever `pi` is on PATH.
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
    "--tools", (options.tools ?? DEFAULT_TOOLS).join(","),
    "--append-system-prompt", CHILD_INSTRUCTIONS,
  ];
  if (options.thinking) args.push("--thinking", options.thinking);
  return args;
}

export function initialDetails(options: DelegateOptions): DelegateDetails {
  return {
    model: `${options.provider}/${options.model}`,
    status: "queued",
    cwd: options.cwd,
    queuedMs: 0,
    elapsedMs: 0,
    output: "",
    stderr: "",
    activity: [],
    turns: 0,
    usage: {
      input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0,
      cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
    },
  };
}

function snapshot(details: DelegateDetails): DelegateDetails {
  return {
    ...details,
    activity: [...details.activity],
    usage: { ...details.usage, cost: { ...details.usage.cost } },
  };
}

function parseEvent(line: string): JsonAgentSessionEvent {
  const parsed = JSON.parse(line);
  if (!parsed || typeof parsed.type !== "string") throw new Error("Missing event type");
  return parsed;
}

function recordActivity(details: DelegateDetails, text: string) {
  details.activity.push(text.slice(0, MAX_ACTIVITY_CHARS));
  details.activity = details.activity.slice(-MAX_ACTIVITY_ENTRIES);
}

// Returns whether there is progress to publish.
function applyEvent(event: JsonAgentSessionEvent, details: DelegateDetails, outcome: Outcome): boolean {
  switch (event.type) {
    case "message_start":
      if (event.message.role === "assistant") details.output = "";
      return false;
    case "message_update": {
      const delta = event.assistantMessageEvent;
      if (delta.type !== "text_delta") return false;
      details.output = (details.output + delta.delta).slice(-MAX_STREAMED_OUTPUT_CHARS);
      return true;
    }
    case "message_end": {
      const message = event.message;
      if (message.role !== "assistant") return false;
      outcome.assistantSeen = true;
      outcome.stopReason = message.stopReason;
      outcome.assistantError = message.errorMessage;
      details.turns++;
      details.output = message.content
        .filter((part) => part.type === "text")
        .map((part) => part.text)
        .join("\n");
      for (const key of USAGE_KEYS) details.usage[key] += message.usage?.[key] ?? 0;
      for (const key of COST_KEYS) details.usage.cost[key] += message.usage?.cost?.[key] ?? 0;
      return true;
    }
    case "tool_execution_start": {
      const args = event.args as Record<string, unknown>;
      const target = args?.command ?? args?.path ?? args?.pattern ?? "";
      recordActivity(details, `→ ${event.toolName} ${String(target)}`);
      return true;
    }
    case "tool_execution_end":
      recordActivity(details, `${event.isError ? "✗" : "✓"} ${event.toolName}`);
      return true;
    case "auto_retry_start":
      recordActivity(details, `Retry ${event.attempt}: ${event.errorMessage}`);
      return true;
    default:
      return false;
  }
}

function failureReason(
  code: number | null,
  exitSignal: string | null,
  outcome: Outcome,
  output: string,
): string | undefined {
  if (code !== 0) return `Child exited with ${exitSignal ? `signal ${exitSignal}` : `code ${code}`}.`;
  if (outcome.assistantSeen && outcome.stopReason !== "stop") {
    return outcome.assistantError || `Child ended with ${outcome.stopReason ?? "no stop reason"}.`;
  }
  if (!outcome.assistantSeen || !output.trim()) return "Child exited without a final text response.";
  return undefined;
}

export async function runDelegate(
  options: DelegateOptions,
  signal?: AbortSignal,
  onUpdate?: (details: DelegateDetails) => void,
  invocation: Invocation = piInvocation(),
  killDelayMs = 5000,
): Promise<DelegateDetails> {
  const startedAt = Date.now();
  const details = initialDetails(options);
  details.status = "running";
  details.queuedMs = Math.max(0, startedAt - (options.queuedAt ?? startedAt));
  if (signal?.aborted) {
    return { ...details, status: "aborted", error: "Delegation cancelled before launch." };
  }

  return new Promise((resolve) => {
    // A POSIX process group lets cancellation reach the child's own subprocesses.
    const grouped = process.platform !== "win32";
    const proc = spawn(invocation.command, [...invocation.args, ...childArguments(options)], {
      cwd: options.cwd,
      shell: false,
      detached: grouped,
      stdio: ["pipe", "pipe", "pipe"],
      env: { ...process.env, PI_DELEGATE_CHILD: "1" },
    });

    const outcome: Outcome = { assistantSeen: false };
    let closed = false;
    let buffer = "";
    let spawnError: string | undefined;
    let protocolError: string | undefined;
    let killTimer: ReturnType<typeof setTimeout> | undefined;
    let updateTimer: ReturnType<typeof setTimeout> | undefined;

    const appendStderr = (text: string) => {
      details.stderr = (details.stderr + text).slice(-MAX_STDERR_CHARS);
    };

    const kill = (sig: NodeJS.Signals) => {
      if (!proc.pid) return;
      try {
        if (grouped) process.kill(-proc.pid, sig);
        else proc.kill(sig);
      } catch (error) {
        if ((error as NodeJS.ErrnoException).code !== "ESRCH") {
          appendStderr(`\nUnable to send ${sig}: ${String(error)}`);
        }
      }
    };
    const terminate = () => {
      if (closed || killTimer) return;
      kill("SIGTERM");
      // proc.killed only means a signal was sent, not that the process exited.
      killTimer = setTimeout(() => kill("SIGKILL"), killDelayMs);
    };
    const abort = () => {
      details.status = "aborted";
      terminate();
    };
    const failProtocol = (message: string) => {
      protocolError ??= message;
      terminate();
    };

    const publish = () => {
      details.elapsedMs = Date.now() - startedAt;
      try {
        onUpdate?.(snapshot(details));
      } catch (error) {
        spawnError = `Could not publish child progress: ${String(error)}`;
        terminate();
      }
    };
    const schedulePublish = () => {
      if (closed || updateTimer) return;
      updateTimer = setTimeout(() => {
        updateTimer = undefined;
        publish();
      }, UPDATE_THROTTLE_MS);
    };

    const handleLine = (line: string) => {
      if (!line.trim() || protocolError) return;
      if (Buffer.byteLength(line) > MAX_RECORD_BYTES) return failProtocol(RECORD_TOO_LARGE);
      let event: JsonAgentSessionEvent;
      try {
        event = parseEvent(line);
      } catch {
        return failProtocol("Child emitted invalid JSONL output.");
      }
      try {
        if (applyEvent(event, details, outcome)) schedulePublish();
      } catch (error) {
        failProtocol(`Invalid child event: ${String(error)}`);
      }
    };

    proc.stdout.setEncoding("utf8");
    proc.stdout.on("data", (chunk: string) => {
      buffer += chunk;
      let newline: number;
      while ((newline = buffer.indexOf("\n")) !== -1) {
        handleLine(buffer.slice(0, newline));
        buffer = buffer.slice(newline + 1);
      }
      if (Buffer.byteLength(buffer) > MAX_RECORD_BYTES) {
        buffer = "";
        failProtocol(RECORD_TOO_LARGE);
      }
    });
    proc.stderr.setEncoding("utf8");
    proc.stderr.on("data", appendStderr);
    proc.stdin.on("error", (error: NodeJS.ErrnoException) => {
      // An early CLI failure may close stdin before accepting the task.
      if (error.code === "EPIPE") return;
      spawnError = `Child stdin failed: ${error.message}`;
      terminate();
    });
    proc.on("error", (error) => {
      spawnError = `Could not start Pi: ${error.message}`;
    });
    proc.on("close", (code, exitSignal) => {
      closed = true;
      signal?.removeEventListener("abort", abort);
      clearTimeout(killTimer);
      clearTimeout(updateTimer);
      clearInterval(heartbeat);
      if (buffer.trim()) handleLine(buffer);

      details.elapsedMs = Date.now() - startedAt;
      details.exitCode = code;
      details.exitSignal = exitSignal;
      if (details.status === "aborted") {
        details.error = "Delegation cancelled.";
      } else {
        details.error = spawnError ?? protocolError
          ?? failureReason(code, exitSignal, outcome, details.output);
        details.status = details.error ? "failed" : "completed";
      }
      resolve(details);
    });

    const heartbeat = setInterval(publish, HEARTBEAT_MS);
    signal?.addEventListener("abort", abort, { once: true });
    if (signal?.aborted) abort();
    publish();
    // stdin avoids argv size limits, @file interpretation, and exposing the task in `ps`.
    proc.stdin.end(`Task: ${options.task}`);
  });
}
