#!/usr/bin/env bash
#
# ~/.config/tmux/scripts/wt-new-window.sh
#
# USAGE
#
#     bind-key B if-shell 'command -v wt >/dev/null 2>&1' {
#       command-prompt -p "window name:" \
#         'run-shell "~/.config/tmux/scripts/wt-new-window.sh %% #{pane_current_path}"'
#     }

window_name="$1"
pane_current_path="$2"

tmux new-window \
    -n "$name" \
    -c "$pane_current_path" \
    "wt switch --create '$window_name' -x $SHELL"
