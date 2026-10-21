#!/bin/sh

selection=$(
    tmux list-panes -a -F '#{session_id}	#{window_id}	#{pane_id}	#{session_name}:#{window_index}	#{window_flags}	#{window_name}	#{pane_index}	#{pane_current_command}	#{pane_current_path}' |
        awk -F '\t' '{
    window = $1 SUBSEP $2
    if (window != previous_window) {
        printf "%s\t%s\t\t%s %s %s\n", $1, $2, $4, $5, $6
        previous_window = window
    }
    printf "%s\t%s\t%s\t    %-12s %-12s %-12s %s\n", $1, $2, $3, $4 "." $7, $6, $8, $9
  }' |
        fzf --tmux=center,40%,30% --delimiter='\t' --with-nth=4 --info=hidden --prompt='> '
) || exit 0

[ -n "$selection" ] || exit 0

session_id=$(printf '%s\n' "$selection" | cut -f1)
window_id=$(printf '%s\n' "$selection" | cut -f2)
pane_id=$(printf '%s\n' "$selection" | cut -f3)

tmux switch-client -t "$session_id"
tmux select-window -t "$window_id"
if [ -n "$pane_id" ]; then
    tmux select-pane -t "$pane_id"
fi
