#!/bin/sh

selection=$(
  tmux list-windows -a -F '#{session_id}	#{window_id}	#{session_name}:#{window_index}	#{window_flags}	#{window_name}	#{pane_current_command}	#{pane_current_path}' |
  awk -F '\t' '{
    printf "%s\t%s\t%-18s %-4s %-28s %-16s %s\n", $1, $2, $3, $4, $5, $6, $7
  }' |
  fzf --tmux=center,70%,60% --delimiter='\t' --nth=1 --with-nth=3 --prompt='window> '
) || exit 0

[ -n "$selection" ] || exit 0

session_id=$(printf '%s\n' "$selection" | cut -f1)
window_id=$(printf '%s\n' "$selection" | cut -f2)

tmux switch-client -t "$session_id"
tmux select-window -t "$window_id"
