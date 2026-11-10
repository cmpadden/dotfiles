export type Status = "idle" | "working" | "waiting" | "done";
export type RunTmux = (args: string[]) => Promise<{ code: number }>;

export const HEARTBEAT_MS = 5_000;
export const LEASE_SECONDS = 20;

// Only one foreground TUI owns a pane. The token prevents a superseded runtime
// (for example during reload) from updating or clearing its successor's state.
export class PaneStatus {
  private state: Status = "idle";
  private stopped = false;
  private queue: Promise<void> = Promise.resolve();
  private timer: ReturnType<typeof setInterval> | undefined;

  private readonly run: RunTmux;
  private readonly pane: string;
  private readonly owner: string;

  constructor(run: RunTmux, pane: string, owner: string) {
    // These values are also interpolated into tmux commands, never shell code.
    if (!/^%\d+$/.test(pane) || !/^[a-zA-Z0-9-]+$/.test(owner)) {
      throw new Error("Invalid tmux pane or owner");
    }
    this.run = run;
    this.pane = pane;
    this.owner = owner;
  }

  private enqueue(command: () => Promise<{ code: number }>): Promise<void> {
    this.queue = this.queue.then(async () => {
      try {
        await command();
      } catch {
        // A missing tmux binary, closed pane, or dead server must not break Pi.
      }
    });
    return this.queue;
  }

  private guarded(command: string): Promise<{ code: number }> {
    return this.run([
      "if-shell", "-F", "-t", this.pane,
      `#{==:#{@pi_status_owner},${this.owner}}`, command,
    ]);
  }

  private publish(): Promise<void> {
    const state = this.state;
    return this.enqueue(() => {
      const until = Math.floor(Date.now() / 1_000) + LEASE_SECONDS;
      return this.guarded(
        `set-option -p -t ${this.pane} @pi_status ${state} ; ` +
        `set-option -p -t ${this.pane} @pi_status_until ${until}`,
      );
    });
  }

  async start(state: Status): Promise<void> {
    this.state = state;
    await this.enqueue(() => this.run([
      "set-option", "-p", "-t", this.pane, "@pi_status_owner", this.owner,
    ]));
    if (this.stopped) return;
    await this.publish();
    if (this.stopped) return;
    this.timer = setInterval(() => void this.publish(), HEARTBEAT_MS);
    this.timer.unref();
  }

  update(state: Status): Promise<void> {
    if (this.stopped || state === this.state) return this.queue;
    this.state = state;
    return this.publish();
  }

  stop(): Promise<void> {
    if (this.stopped) return this.queue;
    this.stopped = true;
    clearInterval(this.timer);
    this.timer = undefined;
    return this.enqueue(() => this.guarded(
      `set-option -pu -t ${this.pane} @pi_status ; ` +
      `set-option -pu -t ${this.pane} @pi_status_until ; ` +
      `set-option -pu -t ${this.pane} @pi_status_owner`,
    ));
  }
}
