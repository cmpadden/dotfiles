import { execFile } from "node:child_process";
import { mkdtemp, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { randomUUID } from "node:crypto";

export const COMMANDS = [
  "status", "list-apps", "list-windows", "snapshot", "get", "click",
  "type", "set-value", "press", "scroll", "screenshot",
] as const;
export type Command = typeof COMMANDS[number];
export type DesktopInput = {
  command: Command;
  app?: string;
  windowId?: string;
  ref?: string;
  text?: string;
  keys?: string;
  property?: "text" | "value" | "title" | "bounds" | "role" | "states";
  direction?: "up" | "down" | "left" | "right";
  amount?: number;
  maxDepth?: number;
  interactiveOnly?: boolean;
  skeleton?: boolean;
  root?: string;
  headed?: boolean;
  timeoutMs?: number;
};

type Envelope = {
  version: string;
  ok: boolean;
  command: string;
  data?: Record<string, unknown>;
  error?: Record<string, unknown>;
};
export type DesktopResult = {
  content: ({ type: "text"; text: string } | { type: "image"; data: string; mimeType: string })[];
  details: { command: string; fullOutputPath?: string; truncated?: boolean };
  isError?: boolean;
};
export type ProcessOptions = {
  cwd: string;
  env: NodeJS.ProcessEnv;
  signal: AbortSignal;
  timeout: number;
  maxBuffer: number;
  stdin?: string;
};
export type ProcessResult = {
  stdout: string;
  stderr: string;
  code: number;
  stopped?: boolean;
  missing?: boolean;
};
export type RunProcess = (binary: string, args: string[], options: ProcessOptions) => Promise<ProcessResult>;

// execFile never invokes a shell. Text goes through stdin, not process arguments.
// Do not pass signal to execFile: Node's AbortError callback can run before close,
// which would release the desktop queue while the previous process is still alive.
export const runProcess: RunProcess = (binary, args, options) => new Promise((resolve) => {
  if (options.signal.aborted) {
    resolve({ stdout: "", stderr: "", code: 1, stopped: true });
    return;
  }
  const child = execFile(binary, args, {
    cwd: options.cwd,
    env: options.env,
    encoding: "utf8",
    timeout: options.timeout,
    maxBuffer: options.maxBuffer,
    killSignal: "SIGKILL",
    windowsHide: true,
  }, (error, stdout, stderr) => {
    options.signal.removeEventListener("abort", abort);
    const code = error && "code" in error ? error.code : undefined;
    resolve({
      stdout, stderr,
      code: error ? (typeof code === "number" ? code : 1) : 0,
      stopped: options.signal.aborted || Boolean(error?.killed) || code === "ERR_CHILD_PROCESS_STDIO_MAXBUFFER",
      missing: code === "ENOENT",
    });
  });
  const abort = () => { child.kill("SIGKILL"); };
  options.signal.addEventListener("abort", abort, { once: true });
  if (options.signal.aborted) abort();
  // An early exit can close stdin before the write finishes (EPIPE).
  child.stdin?.on("error", () => {});
  child.stdin?.end(options.stdin);
});

const MUTATIONS = new Set<Command>(["click", "type", "set-value", "press", "scroll"]);
const FIELDS: Record<Command, string[]> = {
  status: [],
  "list-apps": ["app"],
  "list-windows": ["app"],
  snapshot: ["app", "windowId", "root", "maxDepth", "interactiveOnly", "skeleton"],
  get: ["ref", "property"],
  click: ["ref", "headed"],
  type: ["ref", "text", "headed"],
  "set-value": ["ref", "text", "headed"],
  press: ["app", "windowId", "keys", "headed"],
  scroll: ["ref", "direction", "amount", "headed"],
  screenshot: ["app", "windowId"],
};
const REF = /^@[A-Za-z0-9_-]+:e\d+$/;

function required(value: unknown, field: string, allowEmpty = false): asserts value is string {
  if (typeof value !== "string" || (!allowEmpty && !value.trim()) || value.includes("\0")) {
    throw new Error(`${field} must be ${allowEmpty ? "a" : "a nonempty"} string without NUL bytes`);
  }
}

export function buildInvocation(input: DesktopInput): { args: string[]; stdin?: string } {
  if (!COMMANDS.includes(input.command)) throw new Error("Unsupported desktop command");
  const allowed = new Set(["command", "timeoutMs", ...FIELDS[input.command]]);
  for (const [key, value] of Object.entries(input)) {
    if (value !== undefined && !allowed.has(key)) throw new Error(`${key} is not supported for ${input.command}`);
  }
  for (const field of ["app", "windowId", "keys", "property"] as const) {
    if (input[field] !== undefined) required(input[field], field);
  }
  for (const field of ["ref", "root"] as const) {
    if (input[field] !== undefined && (typeof input[field] !== "string" || !REF.test(input[field]))) {
      throw new Error(`${field} must be a qualified snapshot ref such as @snapshot:e1`);
    }
  }
  for (const [field, min, max] of [["timeoutMs", 100, 60_000], ["maxDepth", 1, 50], ["amount", 1, 100]] as const) {
    const value = input[field];
    if (value !== undefined && (!Number.isInteger(value) || value < min || value > max)) {
      throw new Error(`${field} must be an integer from ${min} to ${max}`);
    }
  }
  for (const field of ["headed", "interactiveOnly", "skeleton"] as const) {
    if (input[field] !== undefined && typeof input[field] !== "boolean") throw new Error(`${field} must be boolean`);
  }
  if (input.property && !["text", "value", "title", "bounds", "role", "states"].includes(input.property)) {
    throw new Error("Unsupported get property");
  }
  if (input.direction && !["up", "down", "left", "right"].includes(input.direction)) {
    throw new Error("Unsupported scroll direction");
  }
  if (["snapshot", "screenshot", "press"].includes(input.command) && !input.app && !input.windowId && !input.root) {
    throw new Error(`${input.command} requires app or windowId (snapshot also accepts root)`);
  }
  if ((MUTATIONS.has(input.command) && input.command !== "press") || input.command === "get") {
    required(input.ref, "ref");
  }
  if (input.command === "press") required(input.keys, "keys");
  if (input.command === "type" || input.command === "set-value") {
    required(input.text, "text", input.command === "set-value");
    const limit = input.command === "type" ? 10_000 : 128 * 1024;
    if (Buffer.byteLength(input.text) > limit) throw new Error(`text exceeds ${limit} bytes`);
  }

  const args = ["--session=pi", ...(input.headed ? ["--headed"] : []), input.command];
  // '=' prevents a value such as '--headed' from being interpreted as a flag.
  if (input.app) args.push(`--app=${input.app}`);
  if (input.windowId) args.push(`--window-id=${input.windowId}`);
  if (input.command === "snapshot") {
    args.push("--compact", `--max-depth=${input.maxDepth ?? 6}`);
    if (input.interactiveOnly !== false) args.push("--interactive-only");
    if (input.skeleton) args.push("--skeleton");
    if (input.root) args.push(`--root=${input.root}`);
  }
  if (input.property) args.push(`--property=${input.property}`);
  if (input.command === "scroll") {
    args.push(`--direction=${input.direction ?? "down"}`, `--amount=${input.amount ?? 3}`);
  }
  if (input.command === "type" || input.command === "set-value") args.push("--stdin");
  // '--' terminates option parsing for all positional values.
  if (input.ref) args.push("--", input.ref);
  if (input.keys) args.push("--", input.keys);
  return { args, stdin: input.text };
}

const MAX_TEXT_BYTES = 50 * 1024;
const MAX_LINES = 2000;
const MAX_IMAGE_BYTES = 8 * 1024 * 1024;

function bounded(text: string): string {
  return Buffer.from(text.split("\n").slice(0, MAX_LINES).join("\n")).subarray(0, MAX_TEXT_BYTES).toString("utf8");
}

export class DesktopRuntime {
  private tail: Promise<unknown> = Promise.resolve();
  private shutdown = new AbortController();
  private directory?: string;
  private closePromise?: Promise<void>;

  private binary: string;
  private run: RunProcess;

  constructor(binary = process.env.PI_AGENT_DESKTOP_BIN || "agent-desktop", run: RunProcess = runProcess) {
    this.binary = binary;
    this.run = run;
  }

  execute(input: DesktopInput, cwd: string, signal?: AbortSignal): Promise<DesktopResult> {
    const combined = signal ? AbortSignal.any([signal, this.shutdown.signal]) : this.shutdown.signal;
    const task = this.tail.then(async () => {
      try {
        combined.throwIfAborted();
        const invocation = buildInvocation(input);
        this.directory ??= await mkdtemp(join(tmpdir(), "pi-agent-desktop-"));
        combined.throwIfAborted();
        const env: NodeJS.ProcessEnv = { ...process.env, AGENT_DESKTOP_HOME: join(this.directory, "state") };
        // Do not join a caller's snapshot namespace / subagent identity.
        delete env.AGENT_DESKTOP_SESSION;
        delete env.AGENT_DESKTOP_AGENT_ID;
        const result = await this.run(this.binary, invocation.args, {
          cwd, env, signal: combined, timeout: input.timeoutMs ?? 15_000,
          maxBuffer: input.command === "screenshot" ? 12 * 1024 * 1024 : 2 * 1024 * 1024,
          stdin: invocation.stdin,
        });
        if (result.missing) throw new Error("agent-desktop not found. Install agent-desktop@1.3.0 or set PI_AGENT_DESKTOP_BIN to an executable path; then retry status.");
        if (result.stopped || combined.aborted) {
          throw new Error("Desktop command cancelled, timed out, or exceeded its output limit. Delivery may be uncertain: observe the UI before repeating any action.");
        }
        let envelope: Envelope;
        try { envelope = JSON.parse(result.stdout); }
        catch { throw new Error(`agent-desktop returned invalid JSON (exit ${result.code}). Delivery may be uncertain; inspect the UI before repeating an action. ${bounded(result.stderr).slice(0, 2000)}`); }
        if (!envelope || typeof envelope !== "object" || typeof envelope.ok !== "boolean" || typeof envelope.version !== "string" || envelope.command !== input.command) {
          throw new Error("Unexpected agent-desktop JSON envelope; check the installed CLI version. Do not repeat an action without observing the UI.");
        }
        const content: DesktopResult["content"] = [];
        if (input.command === "screenshot" && envelope.ok) {
          const { data, format, ...metadata } = envelope.data ?? {};
          if (format !== "png" || typeof data !== "string" || !/^[A-Za-z0-9+/]+={0,2}$/.test(data) || Buffer.byteLength(data, "base64") > MAX_IMAGE_BYTES || !Buffer.from(data, "base64").subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) {
            throw new Error("Expected a PNG screenshot of at most 8 MiB");
          }
          envelope = { ...envelope, data: { ...metadata, format } };
          content.push({ type: "image", data, mimeType: "image/png" });
        }
        const fullText = JSON.stringify(envelope, null, 2);
        let text = bounded(fullText);
        const details: DesktopResult["details"] = { command: input.command };
        if (text !== fullText) {
          const path = join(this.directory, `output-${randomUUID()}.json`);
          await writeFile(path, fullText, { mode: 0o600 });
          details.fullOutputPath = path;
          details.truncated = true;
          text += `\n[Truncated to 50 KiB/2000 lines. Full JSON: ${path}; removed on /reload or shutdown. Narrow the snapshot with root, maxDepth, or skeleton.]`;
        }
        if (result.code !== 0 && envelope.ok) text += `\n[CLI exited with code ${result.code}; treat this result as a failure.]`;
        content.unshift({ type: "text", text });
        return { content, details, isError: !envelope.ok || result.code !== 0 };
      } catch (error) {
        // Never stringify subprocess exceptions: they can include command text.
        return {
          content: [{ type: "text" as const, text: combined.aborted ? "Desktop call cancelled. If an action was running, inspect the UI before repeating it." : error instanceof Error ? error.message : "Desktop command failed" }],
          details: { command: input.command }, isError: true,
        };
      }
    });
    this.tail = task.catch(() => {});
    return task;
  }

  close(): Promise<void> {
    this.shutdown.abort();
    return this.closePromise ??= (async () => {
      await this.tail;
      if (this.directory) await rm(this.directory, { recursive: true, force: true });
    })();
  }
}
