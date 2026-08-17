import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

type PullRequest = {
  number: number;
  title: string;
  url: string;
};

type Check = {
  bucket: "pass" | "fail" | "pending" | "skipping" | "cancel";
  link: string;
  name: string;
  state: string;
  workflow: string;
};

type Monitor = {
  pr: PullRequest;
  intervalMs: number;
  timer?: ReturnType<typeof setInterval>;
  checks: Map<string, Check["bucket"]>;
  pollInFlight: boolean;
  failedChecks: Set<string>;
  hadPollError: boolean;
  generation: number;
};

const DEFAULT_INTERVAL_MS = 60_000;
const MIN_INTERVAL_SECONDS = 15;
let monitor: Monitor | undefined;

function checkKey(check: Check): string {
  return `${check.workflow}\u0000${check.name}\u0000${check.link}`;
}

function formatSummary(checks: Check[]): string {
  const counts = new Map<Check["bucket"], number>();
  for (const check of checks) counts.set(check.bucket, (counts.get(check.bucket) ?? 0) + 1);

  const parts = (["fail", "cancel", "pending", "pass", "skipping"] as const)
    .flatMap((bucket) => {
      const count = counts.get(bucket);
      return count ? [`${count} ${bucket === "pass" ? "passed" : bucket}`] : [];
    });
  return parts.length ? parts.join(", ") : "no checks reported";
}

function updateStatus(ctx: ExtensionContext, checks?: Check[]): void {
  if (!monitor) {
    ctx.ui.setStatus("gh-monitor-ci", undefined);
    return;
  }
  const summary = checks ? formatSummary(checks) : "starting";
  const color = checks?.some((check) => check.bucket === "fail") ? "error" : "accent";
  ctx.ui.setStatus("gh-monitor-ci", ctx.ui.theme.fg(color, `CI #${monitor.pr.number}: ${summary}`));
}

async function resolvePullRequest(pi: ExtensionAPI, cwd: string, ref?: string): Promise<PullRequest> {
  const args = ["pr", "view"];
  if (ref) args.push(ref);
  args.push("--json", "number,title,url");
  const result = await pi.exec("gh", args, { cwd, timeout: 15_000 });
  if (result.code !== 0) throw new Error(result.stderr.trim() || "Unable to find a pull request for this branch.");
  return JSON.parse(result.stdout) as PullRequest;
}

async function poll(pi: ExtensionAPI, ctx: ExtensionContext, expectedGeneration: number): Promise<void> {
  const current = monitor;
  if (!current || current.generation !== expectedGeneration || current.pollInFlight) return;
  current.pollInFlight = true;

  try {
    const result = await pi.exec(
      "gh",
      ["pr", "checks", current.pr.url, "--json", "bucket,link,name,state,workflow"],
      { cwd: ctx.cwd, timeout: 30_000 },
    );
    let checks: Check[];
    try {
      checks = JSON.parse(result.stdout) as Check[];
    } catch {
      throw new Error(result.stderr.trim() || "GitHub returned an invalid CI response.");
    }
    if (!monitor || monitor.generation !== expectedGeneration) return;

    if (current.hadPollError) ctx.ui.notify(`CI monitor reconnected for PR #${current.pr.number}.`, "info");
    current.hadPollError = false;
    updateStatus(ctx, checks);

    for (const check of checks) {
      const key = checkKey(check);
      const previous = current.checks.get(key);
      if (check.bucket === "fail" && previous !== "fail") {
        ctx.ui.notify(
          `CI failure: ${check.workflow ? `${check.workflow} / ` : ""}${check.name}${check.link ? ` — ${check.link}` : ""}`,
          "error",
        );
        current.failedChecks.add(key);
      } else if (check.bucket === "cancel" && previous !== "cancel") {
        ctx.ui.notify(`CI cancelled: ${check.workflow ? `${check.workflow} / ` : ""}${check.name}`, "warning");
      } else if (check.bucket === "pass" && previous === "fail" && current.failedChecks.has(key)) {
        ctx.ui.notify(
          `Possible CI flake: ${check.workflow ? `${check.workflow} / ` : ""}${check.name} failed, then passed after a rerun.`,
          "warning",
        );
      }
      current.checks.set(key, check.bucket);
    }
  } catch (error) {
    if (!monitor || monitor.generation !== expectedGeneration) return;
    if (!current.hadPollError) {
      const message = error instanceof Error ? error.message : String(error);
      ctx.ui.notify(`CI monitor error: ${message}`, "warning");
    }
    current.hadPollError = true;
  } finally {
    if (monitor?.generation === expectedGeneration) current.pollInFlight = false;
  }
}

function stop(ctx: ExtensionContext, message?: string): void {
  if (monitor?.timer) clearInterval(monitor.timer);
  monitor = undefined;
  updateStatus(ctx);
  if (message) ctx.ui.notify(message, "info");
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand("ci", {
    description: "Poll the current PR's GitHub CI every minute; use stop, status, or an optional PR number/URL",
    handler: async (args, ctx) => {
      const input = args.trim();
      if (input === "stop") {
        if (!monitor) {
          ctx.ui.notify("CI monitor is not running.", "info");
          return;
        }
        stop(ctx, "CI monitor stopped.");
        return;
      }
      if (input === "status") {
        if (!monitor) {
          ctx.ui.notify("CI monitor is not running.", "info");
          return;
        }
        ctx.ui.notify(`Monitoring PR #${monitor.pr.number}: ${monitor.pr.title}`, "info");
        return;
      }

      const intervalMatch = input.match(/^interval\s+(\d+)$/);
      if (intervalMatch) {
        if (!monitor) {
          ctx.ui.notify("Start the CI monitor before changing its interval.", "warning");
          return;
        }
        const seconds = Number(intervalMatch[1]);
        if (seconds < MIN_INTERVAL_SECONDS) {
          ctx.ui.notify(`Interval must be at least ${MIN_INTERVAL_SECONDS} seconds.`, "warning");
          return;
        }
        clearInterval(monitor.timer);
        monitor.intervalMs = seconds * 1_000;
        const generation = monitor.generation;
        monitor.timer = setInterval(() => void poll(pi, ctx, generation), monitor.intervalMs);
        ctx.ui.notify(`CI monitor interval set to ${seconds}s.`, "info");
        return;
      }

      if (monitor) stop(ctx);
      try {
        const pr = await resolvePullRequest(pi, ctx.cwd, input || undefined);
        monitor = {
          pr,
          intervalMs: DEFAULT_INTERVAL_MS,
          checks: new Map(),
          pollInFlight: false,
          failedChecks: new Set(),
          hadPollError: false,
          generation: Date.now(),
        };
        const generation = monitor.generation;
        monitor.timer = setInterval(() => void poll(pi, ctx, generation), monitor.intervalMs);
        ctx.ui.notify(`Monitoring CI for PR #${pr.number} every 60s. Use /ci stop to stop.`, "info");
        await poll(pi, ctx, generation);
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        ctx.ui.notify(`Could not start CI monitor: ${message}`, "error");
      }
    },
  });

  pi.on("session_shutdown", async (_event, ctx) => {
    if (monitor) stop(ctx);
  });
}
