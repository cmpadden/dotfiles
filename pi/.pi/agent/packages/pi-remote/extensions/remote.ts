import { readFile } from "node:fs/promises";
import { createServer, type IncomingMessage, type Server, type ServerResponse } from "node:http";
import type { AddressInfo } from "node:net";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { CURSOR_MARKER, type Component, type Focusable, type KeybindingsManager, truncateToWidth } from "@earendil-works/pi-tui";
import * as ngrok from "@ngrok/ngrok";
import qrcode from "qrcode-terminal";
import { parseRemoteArgs, snapshotMessages } from "../lib/core.mjs";
import { NGROK_AUTHTOKEN_URL, resolveNgrokAuthtoken } from "../lib/ngrok-auth.mjs";
import { saveNgrokAuthtoken } from "../lib/ngrok-storage.mjs";
import { renderMarkdown } from "../lib/markdown.mjs";
import {
  SESSION_COOKIE,
  SESSION_TTL_SECONDS,
  createPairing,
  pairingUrl,
  parseCookies,
  randomToken,
  sessionCookie,
  tokenHash,
  tokenMatches,
} from "../lib/pairing.mjs";

const STATUS_KEY = "pi-remote";
const WIDGET_KEY = "pi-remote-qr";
const MAX_BODY_BYTES = 256 * 1024;
const WEB_HTML_URL = new URL("../web/index.html", import.meta.url);

type RemoteState = {
  localUrl: string;
  publicUrl: string;
  server: Server;
  listener: ngrok.Listener;
  clients: Set<ServerResponse>;
  pairingHash: Buffer | undefined;
  pairingExpiresAt: number;
  sessions: Map<string, number>;
  failedPairings: Map<string, number[]>;
};

type SecretPromptTheme = {
  fg(color: "accent" | "muted" | "dim" | "error", text: string): string;
  bold(text: string): string;
};

class SecretPrompt implements Component, Focusable {
  focused = false;
  private value = "";
  private paste = "";
  private pasting = false;
  private readonly theme: SecretPromptTheme;
  private readonly keybindings: KeybindingsManager;
  private readonly done: (value: string | undefined) => void;
  private readonly requestRender: () => void;

  constructor(
    theme: SecretPromptTheme,
    keybindings: KeybindingsManager,
    done: (value: string | undefined) => void,
    requestRender: () => void,
  ) {
    this.theme = theme;
    this.keybindings = keybindings;
    this.done = done;
    this.requestRender = requestRender;
  }

  handleInput(data: string): void {
    if (data.includes("\x1b[200~")) {
      this.pasting = true;
      this.paste = "";
      data = data.replace("\x1b[200~", "");
    }
    if (this.pasting) {
      this.paste += data;
      const end = this.paste.indexOf("\x1b[201~");
      if (end === -1) return;
      this.value += this.paste.slice(0, end).replace(/[\r\n\s]+/g, "");
      data = this.paste.slice(end + 6);
      this.paste = "";
      this.pasting = false;
    }

    if (this.keybindings.matches(data, "tui.select.cancel")) {
      this.clear();
      this.done(undefined);
      return;
    }
    if (this.keybindings.matches(data, "tui.input.submit") || data === "\n") {
      const value = this.value;
      this.clear();
      this.done(value);
      return;
    }
    if (this.keybindings.matches(data, "tui.editor.deleteCharBackward")) {
      this.value = this.value.slice(0, -1);
    } else if (this.keybindings.matches(data, "tui.editor.deleteToLineStart")) {
      this.clear();
    } else if (![...data].some((char) => char.charCodeAt(0) < 32 || char.charCodeAt(0) === 127)) {
      this.value += data;
    }
    this.requestRender();
  }

  render(width: number): string[] {
    const masked = "•".repeat(Math.min(this.value.length, Math.max(0, width - 4)));
    const cursor = this.focused ? CURSOR_MARKER : "";
    return [
      truncateToWidth(this.theme.fg("accent", this.theme.bold("Paste ngrok authtoken")), width),
      "",
      truncateToWidth(this.theme.fg("muted", "The token stays out of Pi's conversation and is masked on screen."), width),
      truncateToWidth(`  ${masked}${cursor}\x1b[7m \x1b[27m`, width),
      "",
      truncateToWidth(this.theme.fg("dim", "enter save • esc cancel"), width),
    ];
  }

  invalidate(): void {}

  private clear(): void {
    this.value = "";
    this.paste = "";
  }
}

function json(res: ServerResponse, status: number, body: unknown): void {
  res.writeHead(status, {
    "content-type": "application/json; charset=utf-8",
    "cache-control": "no-store",
    "x-content-type-options": "nosniff",
    "referrer-policy": "no-referrer",
  });
  res.end(JSON.stringify(body));
}

function sameOrigin(req: IncomingMessage): boolean {
  const origin = req.headers.origin;
  if (!origin) return true;
  try {
    const expectedHost = String(req.headers["x-forwarded-host"] || req.headers.host || "");
    return new URL(origin).host === expectedHost;
  } catch {
    return false;
  }
}

async function readJson(req: IncomingMessage): Promise<Record<string, unknown>> {
  const chunks: Buffer[] = [];
  let size = 0;
  for await (const chunk of req) {
    const buffer = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    size += buffer.length;
    if (size > MAX_BODY_BYTES) throw new Error("Request body is too large");
    chunks.push(buffer);
  }
  if (!chunks.length) return {};
  return JSON.parse(Buffer.concat(chunks).toString("utf8")) as Record<string, unknown>;
}

function qrLines(url: string): Promise<string[]> {
  return new Promise((resolve) => {
    qrcode.generate(url, { small: true }, (value) => resolve(String(value).trimEnd().split("\n")));
  });
}

async function startNgrok(localUrl: string, authtoken: string): Promise<{ listener: ngrok.Listener; publicUrl: string }> {
  try {
    const listener = await ngrok.forward({
      addr: localUrl,
      authtoken,
      schemes: ["HTTPS"],
      session_metadata: "Pi Remote",
    });
    const publicUrl = listener.url();
    if (!publicUrl) {
      await listener.close();
      throw new Error("ngrok opened a listener without reporting its public URL");
    }
    return { listener, publicUrl };
  } catch (error) {
    const message = error instanceof Error ? error.message : String(error);
    if (/authentication failed|authtoken|ERR_NGROK_4018/i.test(message)) {
      throw new Error("ngrok authentication failed. Run /remote setup to replace the saved authtoken.");
    }
    throw new Error(`ngrok failed to open a tunnel: ${message}`);
  }
}

async function closeServer(server: Server): Promise<void> {
  await new Promise<void>((resolve) => server.close(() => resolve()));
}

async function stopRemote(state: RemoteState | undefined): Promise<void> {
  if (!state) return;
  for (const client of state.clients) client.end();
  state.clients.clear();
  await state.listener.close().catch(() => {});
  await closeServer(state.server).catch(() => {});
}

export default function remoteExtension(pi: ExtensionAPI) {
  let remote: RemoteState | undefined;

  const broadcast = (event: unknown) => {
    if (!remote) return;
    const frame = `data: ${JSON.stringify(event)}\n\n`;
    for (const client of remote.clients) client.write(frame);
  };

  const setBusy = (busy: boolean) => broadcast({ type: "state", busy });

  pi.on("agent_start", () => setBusy(true));
  pi.on("agent_settled", () => setBusy(false));
  pi.on("message_start", (event) => {
    if (event.message.role === "user") {
      const messages = snapshotMessages([{ type: "message", message: event.message }]);
      if (messages[0]) broadcast({ type: "user", text: messages[0].text });
    } else if (event.message.role === "assistant") {
      broadcast({ type: "assistant_start" });
    }
  });
  pi.on("message_update", (event) => {
    if (event.assistantMessageEvent.type === "text_delta") {
      broadcast({ type: "assistant_delta", text: event.assistantMessageEvent.delta });
    }
  });
  pi.on("message_end", (event) => {
    if (event.message.role !== "assistant") return;
    const messages = snapshotMessages([{ type: "message", message: event.message }]);
    broadcast({
      type: "assistant_end",
      text: messages[0]?.text || "",
      error: event.message.stopReason === "error",
    });
  });
  pi.on("tool_execution_start", (event) => {
    broadcast({ type: "tool_start", id: event.toolCallId, name: event.toolName });
  });
  pi.on("tool_execution_end", (event) => {
    broadcast({ type: "tool_end", id: event.toolCallId, name: event.toolName, error: event.isError });
  });
  pi.on("session_shutdown", async () => {
    const current = remote;
    remote = undefined;
    await stopRemote(current);
  });

  function isAuthenticated(req: IncomingMessage): boolean {
    if (!remote) return false;
    const token = parseCookies(req.headers.cookie)[SESSION_COOKIE];
    if (typeof token !== "string") return false;
    const hash = tokenHash(token).toString("hex");
    const expiresAt = remote.sessions.get(hash);
    if (!expiresAt || expiresAt < Date.now()) {
      remote.sessions.delete(hash);
      return false;
    }
    return true;
  }

  function recordFailedPairing(req: IncomingMessage): boolean {
    if (!remote) return false;
    const key = req.socket.remoteAddress || "unknown";
    const cutoff = Date.now() - 60_000;
    const attempts = (remote.failedPairings.get(key) || []).filter((timestamp) => timestamp >= cutoff);
    attempts.push(Date.now());
    remote.failedPairings.set(key, attempts);
    return attempts.length > 10;
  }

  async function handleRequest(req: IncomingMessage, res: ServerResponse, ctx: ExtensionCommandContext): Promise<void> {
    const url = new URL(req.url || "/", "http://localhost");
    if (req.method === "GET" && url.pathname === "/") {
      res.writeHead(200, {
        "content-type": "text/html; charset=utf-8",
        "cache-control": "no-store",
        "content-security-policy": "default-src 'self'; script-src 'unsafe-inline'; style-src 'unsafe-inline' https://fonts.googleapis.com; font-src https://fonts.gstatic.com; connect-src 'self'; img-src 'none'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'",
        "x-frame-options": "DENY",
        "x-content-type-options": "nosniff",
        "referrer-policy": "no-referrer",
      });
      res.end(await readFile(WEB_HTML_URL, "utf8"));
      return;
    }
    if (req.method === "POST" && url.pathname === "/api/pair") {
      if (!sameOrigin(req)) {
        json(res, 403, { error: "Cross-origin request denied" });
        return;
      }
      if (!remote || recordFailedPairing(req)) {
        json(res, 429, { error: "Too many pairing attempts; wait one minute" });
        return;
      }
      try {
        const body = await readJson(req);
        const secret = typeof body.secret === "string" ? body.secret : "";
        const valid = Date.now() <= remote.pairingExpiresAt && tokenMatches(secret, remote.pairingHash);
        if (!valid) {
          json(res, 401, { error: "Pairing link is invalid, expired, or already used" });
          return;
        }
        const sessionToken = randomToken();
        remote.pairingHash = undefined;
        remote.pairingExpiresAt = 0;
        remote.failedPairings.clear();
        remote.sessions.set(tokenHash(sessionToken).toString("hex"), Date.now() + SESSION_TTL_SECONDS * 1000);
        ctx.ui.setWidget(WIDGET_KEY, [`Remote session active ${remote.publicUrl} • Run /remote close to stop`]);
        res.setHeader("set-cookie", sessionCookie(sessionToken));
        json(res, 200, { ok: true });
      } catch (error) {
        json(res, 400, { error: error instanceof Error ? error.message : String(error) });
      }
      return;
    }
    if (url.pathname.startsWith("/api/") && !isAuthenticated(req)) {
      json(res, 401, { error: "Pair this browser by scanning the current Pi Remote QR code" });
      return;
    }
    if (req.method === "GET" && url.pathname === "/api/snapshot") {
      json(res, 200, {
        messages: snapshotMessages(ctx.sessionManager.getBranch()),
        busy: !ctx.isIdle(),
      });
      return;
    }
    if (req.method === "POST" && url.pathname === "/api/markdown") {
      try {
        const body = await readJson(req);
        const markdown = typeof body.markdown === "string" ? body.markdown : "";
        if (markdown.length > 128_000) throw new Error("Markdown is too large to render");
        json(res, 200, { html: await renderMarkdown(markdown) });
      } catch (error) {
        json(res, 400, { error: error instanceof Error ? error.message : String(error) });
      }
      return;
    }
    if (req.method === "GET" && url.pathname === "/api/events") {
      res.writeHead(200, {
        "content-type": "text/event-stream; charset=utf-8",
        "cache-control": "no-cache, no-store, no-transform",
        connection: "keep-alive",
        "content-encoding": "identity",
        "x-accel-buffering": "no",
      });
      res.flushHeaders();
      res.write(`retry: 1500\ndata: ${JSON.stringify({ type: "state", busy: !ctx.isIdle() })}\n\n`);
      remote?.clients.add(res);
      const keepalive = setInterval(() => res.write(": keepalive\n\n"), 15_000);
      req.once("close", () => {
        clearInterval(keepalive);
        remote?.clients.delete(res);
      });
      return;
    }
    if (req.method === "POST" && !sameOrigin(req)) {
      json(res, 403, { error: "Cross-origin request denied" });
      return;
    }
    if (req.method === "POST" && url.pathname === "/api/prompt") {
      try {
        const body = await readJson(req);
        const text = typeof body.text === "string" ? body.text.trim() : "";
        if (!text || text.length > 32_000) throw new Error("Prompt must be between 1 and 32,000 characters");
        pi.sendUserMessage(text, ctx.isIdle() ? undefined : { deliverAs: "followUp" });
        json(res, 202, { ok: true });
      } catch (error) {
        json(res, 400, { error: error instanceof Error ? error.message : String(error) });
      }
      return;
    }
    if (req.method === "POST" && url.pathname === "/api/abort") {
      ctx.abort();
      json(res, 202, { ok: true });
      return;
    }
    json(res, 404, { error: "Not found" });
  }

  async function setupNgrok(ctx: ExtensionCommandContext): Promise<{ token: string; source: string } | undefined> {
    if (ctx.mode !== "tui") {
      throw new Error("Masked ngrok setup is available in Pi's terminal UI. Set NGROK_AUTHTOKEN before starting Pi in other modes.");
    }

    const continueSetup = await ctx.ui.custom<boolean>((tui, theme, keybindings, done) => ({
      render: (width) => [
        truncateToWidth(theme.fg("accent", theme.bold("Connect ngrok")), width),
        "",
        truncateToWidth("Pi Remote will open ngrok's Your Authtoken page in your browser.", width),
        truncateToWidth("Sign up or log in, copy the authtoken shown there, then return to Pi.", width),
        truncateToWidth("You will paste it into a masked field and choose whether to save it.", width),
        "",
        truncateToWidth(theme.fg("dim", "enter continue • esc cancel"), width),
      ],
      handleInput: (data) => {
        if (keybindings.matches(data, "tui.input.submit") || data === "\n") done(true);
        else if (keybindings.matches(data, "tui.select.cancel")) done(false);
        else tui.requestRender();
      },
      invalidate: () => {},
    }));
    if (!continueSetup) return undefined;

    const opener = process.platform === "darwin" ? ["open", [NGROK_AUTHTOKEN_URL]] : process.platform === "win32" ? ["cmd", ["/c", "start", "", NGROK_AUTHTOKEN_URL]] : ["xdg-open", [NGROK_AUTHTOKEN_URL]];
    ctx.ui.notify(`Opening ngrok's Your Authtoken page:\n${NGROK_AUTHTOKEN_URL}`, "info");
    await pi.exec(opener[0] as string, opener[1] as string[]).catch(() => undefined);

    const token = await ctx.ui.custom<string | undefined>((tui, theme, keybindings, done) =>
      new SecretPrompt(theme as SecretPromptTheme, keybindings, done, () => tui.requestRender()),
    );
    if (!token) return undefined;

    const persistence = await ctx.ui.select("Use ngrok authtoken", ["Save to ngrok config", "Use once", "Cancel"]);
    if (!persistence || persistence === "Cancel") return undefined;
    if (persistence === "Save to ngrok config") {
      const path = await saveNgrokAuthtoken(token);
      ctx.ui.notify(`ngrok authtoken saved with owner-only permissions to ${path}`, "info");
      return { token, source: path };
    }
    return { token, source: "this Pi process" };
  }

  async function requireNgrokAuth(ctx: ExtensionCommandContext): Promise<{ token: string; source: string } | undefined> {
    const existing = await resolveNgrokAuthtoken();
    return existing ?? setupNgrok(ctx);
  }

  async function showQr(ctx: ExtensionCommandContext, pairUrl: string): Promise<void> {
    if (ctx.mode !== "tui") {
      ctx.ui.setWidget(WIDGET_KEY, ["Pi Remote pairing link", pairUrl, "Single use • expires in 5 minutes", "Close with /remote close"]);
      return;
    }
    const lines = await qrLines(pairUrl);
    ctx.ui.setWidget(WIDGET_KEY, (_tui, theme) => ({
      render: (width) => [
        truncateToWidth(theme.fg("accent", theme.bold("Pi Remote")), width),
        "",
        ...lines.map((line) => truncateToWidth(line, width, "")),
        "",
        truncateToWidth(theme.fg("muted", "Scan to pair • single use • expires in 5 minutes"), width),
        truncateToWidth(theme.fg("dim", "Run /remote to rotate • /remote close to stop"), width),
      ],
      invalidate: () => {},
    }));
  }

  async function rotatePairing(ctx: ExtensionCommandContext): Promise<void> {
    if (!remote) return;
    const pairing = createPairing();
    remote.pairingHash = pairing.hash;
    remote.pairingExpiresAt = pairing.expiresAt;
    remote.failedPairings.clear();
    await showQr(ctx, pairingUrl(remote.publicUrl, pairing.secret));
  }

  async function open(ctx: ExtensionCommandContext): Promise<void> {
    if (remote) {
      await rotatePairing(ctx);
      ctx.ui.notify("Pi Remote pairing QR rotated; existing paired browsers remain connected", "info");
      return;
    }
    if (!ctx.hasUI) throw new Error("/remote requires interactive setup");
    const auth = await requireNgrokAuth(ctx);
    if (!auth) return;

    ctx.ui.setStatus(STATUS_KEY, "remote: starting…");
    const clients = new Set<ServerResponse>();
    const server = createServer((req, res) => {
      void handleRequest(req, res, ctx).catch((error) => json(res, 500, { error: error instanceof Error ? error.message : String(error) }));
    });
    try {
      await new Promise<void>((resolve, reject) => {
        server.once("error", reject);
        server.listen(0, "127.0.0.1", () => resolve());
      });
      const address = server.address() as AddressInfo;
      const localUrl = `http://127.0.0.1:${address.port}`;
      const tunnel = await startNgrok(localUrl, auth.token);
      remote = {
        localUrl,
        publicUrl: tunnel.publicUrl,
        server,
        listener: tunnel.listener,
        clients,
        pairingHash: undefined,
        pairingExpiresAt: 0,
        sessions: new Map(),
        failedPairings: new Map(),
      };

      ctx.ui.setStatus(STATUS_KEY, "remote: paired access");
      await rotatePairing(ctx);
      ctx.ui.notify(`Pi Remote ready:\n${tunnel.publicUrl}`, "info");
    } catch (error) {
      server.close();
      ctx.ui.setStatus(STATUS_KEY, undefined);
      throw error;
    }
  }

  pi.registerCommand("remote", {
    description: "Open a QR-paired mobile view of this Pi session",
    getArgumentCompletions: (prefix) => ["setup", "status", "close"].filter((value) => value.startsWith(prefix)).map((value) => ({ value, label: value })),
    handler: async (args, ctx) => {
      try {
        const action = parseRemoteArgs(args);
        if (action === "setup") {
          await setupNgrok(ctx);
          return;
        }
        if (action === "status") {
          ctx.ui.notify(
            remote
              ? `Pi Remote is running\n${remote.publicUrl}\nPaired browsers: ${remote.sessions.size}\nPairing: ${remote.pairingHash && remote.pairingExpiresAt >= Date.now() ? "available" : "used or expired"}`
              : "Pi Remote is stopped",
            "info",
          );
          return;
        }
        if (action === "close") {
          const current = remote;
          remote = undefined;
          await stopRemote(current);
          ctx.ui.setStatus(STATUS_KEY, undefined);
          ctx.ui.setWidget(WIDGET_KEY, undefined);
          ctx.ui.notify(current ? "Pi Remote closed" : "Pi Remote was already stopped", "info");
          return;
        }
        await open(ctx);
      } catch (error) {
        ctx.ui.setStatus(STATUS_KEY, undefined);
        ctx.ui.notify(`Pi Remote failed: ${error instanceof Error ? error.message : String(error)}`, "error");
      }
    },
  });
}
