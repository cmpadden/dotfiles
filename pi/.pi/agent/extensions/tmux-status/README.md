# tmux-status

Inject pi status into tmux statuslines.

```text
     0 editor [π:running π:stopped] 1 backend 2 review [π:idle]
```

## States

- `idle` → `π:idle`: Pi is open but has not completed a run in this session, or was aborted; displayed on a light yellow background.
- `working` → `π:running`: a run (including tools, retries, queued continuations, or compaction) is in progress; displayed on a muted green background.
- `waiting` → `π:waiting`: a blocking extension UI prompt needs input; displayed on a muted red background.
- `done` → `π:stopped`: the full run settled; displayed on a muted red background until the next run starts. Any completed response requires review, not just questions.

Each window shows one indicator per live Pi pane, in pane order, inside shared
brackets. The entire `π:state` is colored; brackets and separators stay neutral.
State words use their natural width without padding; state changes preserve pane
order. Starting or exiting sessions adds or removes indicators; windows without
Pi have no badge.

## Usage

Stow both the `pi` and `tmux` packages, then use:

```tmux
set -g status-interval 1
set -g @pi_status_badge '#(sh ~/.config/tmux/scripts/pi-status.sh #{q:socket_path} #{window_id})'

set -g window-status-format "#I #W#{E:@pi_status_badge}"
set -g window-status-current-format "#{?window_zoomed_flag,*,}#[fg=#000000,bg=default,bold,noreverse]#I #W#[default]#{E:@pi_status_badge}"
```

## Cached rendering

Pi publishes pane-local state with a 20-second lease, renewed every five seconds.
The tmux helper scans each window's panes in a background `#()` job, filters expired
leases, and emits a bracketed list of per-pane indicators. tmux caches that result
per client/window and keeps showing it while the next job runs. Updates normally appear within about a second;
exits, pane moves, and expired leases are picked up without a running Pi process.

Status redraws only read the cached result: no nested pane loops or lease
arithmetic run inside tmux's format-expansion time budget. A missing or empty
badge cannot remove the window index or name. No cache files or daemon are needed.

Reload tmux with **prefix+r** after updating. Existing Pi sessions can keep running;
the pane status protocol is unchanged.
