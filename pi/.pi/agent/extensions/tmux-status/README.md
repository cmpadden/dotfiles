# Pi status in tmux

A local, dependency-free Pi extension. No npm Pi package or TPM plugin is needed.
It is auto-discovered through the Stow-managed `~/.pi/agent/extensions/` directory.
Run `/reload` in existing Pi sessions, then reload tmux with **prefix + r**.

The single status row shows window numbers and names, with a badge for windows
containing live, interactive Pi sessions, for example:

```text
     0 editor [pi:working]   1 backend   2 review [pi:waiting]
```

The current window's summary is highlighted using reverse video. No hard-coded
colors, AI naming, completion sounds, or window renaming are involved.
**Prefix + Space** hides or restores the status bar.

## States

- `idle`: Pi is open but has not completed a run in this session, or was aborted.
- `working`: a run (including tools, retries, queued continuations, or compaction)
  is in progress.
- `waiting`: a blocking extension UI prompt needs input. A question written in
  normal assistant text is not detectable as a UI prompt.
- `done`: the full run settled. This is a status, not an unread notification: it
  remains until the next run, session replacement/reload, or exit. Visiting the
  window does not clear it. It does not distinguish a successful answer from a
  provider error; an aborted run returns to `idle` instead.

Each window combines its panes with priority **waiting > working > done > idle**.
One pane finishing or exiting cannot erase another pane's activity. State follows
panes when they move between windows. Only one foreground Pi TUI per pane is
supported; a newer TUI supersedes the previous owner. Print, JSON, and RPC runs
are ignored even when they inherit `TMUX_PANE`, including delegated children.
The parent remains `working` while it awaits a delegated tool; detached children
are not tracked independently.

## Implementation

`index.ts` observes Pi's lifecycle. In particular, `agent_settled`, not
`agent_end`, marks completion. `runtime.ts` serializes bounded tmux calls and
publishes these pane-local user options:

- `@pi_status`: the state word.
- `@pi_status_until`: lease expiration, in Unix seconds.
- `@pi_status_owner`: an opaque token protecting replacement runtimes.

A five-second heartbeat renews the twenty-second lease. Graceful shutdown
(including `/reload`, `/new`, and `/resume`) clears the options and timer. After a
crash or SIGKILL, tmux stops rendering the expired state within roughly twenty
seconds, without needing another Pi session to clean it up. Stale options may
remain until the pane is closed or claimed again. tmux failures never block an
agent operation beyond the command timeout.

`tmux/.config/tmux/tmux.conf` owns all presentation. Its pane loop ignores expired
leases and its window formats render the badge inline, so there is no shared
window-wide status writer and no aggregation race between Pi processes. It uses
tmux's normal one-second status refresh, without shell commands on each redraw.
No prompts, paths, credentials, or conversation text are stored or exposed.

This follows the state-option approach of
[pi-tmux-status](https://github.com/muzammil-iftikhar/pi-tmux-status), but is an
independent implementation rather than copied upstream source.

## Validation

From the dotfiles repository root, using Node 24+:

```sh
node --test pi/.pi/agent/extensions/tmux-status/status.test.ts
```

The suite covers lifecycle transitions, prompt waiting, compaction, noninteractive
children, heartbeats, and shutdown. It also starts an isolated tmux server to test
the real formats, cross-pane priority, inline badges, expired leases, pane
moves, and owner-safe cleanup. That integration test skips if tmux is unavailable.
