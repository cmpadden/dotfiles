#!/bin/sh

# tmux caches #() output while this job refreshes, keeping pane scans out of
# status-line format expansion. Use IDs and an explicit socket for any server.
[ "$#" -eq 2 ] || exit 1
panes=$(tmux -S "$1" list-panes -t "$2" -F '#{@pi_status} #{@pi_status_until}' 2>/dev/null) || exit 1

printf '%s\n' "$panes" | awk -v now="$(date +%s)" '
    BEGIN {
        priority["idle"] = 1
        priority["working"] = 2
        priority["done"] = 3
        priority["waiting"] = 4
    }
    NF == 2 && $2 ~ /^[0-9]+$/ && $2 > now && priority[$1] > best {
        best = priority[$1]
        state = $1
    }
    END {
        # A blank line explicitly clears a previously cached badge.
        if (state == "done")
            print " [pi:#[push-default]#[fg=default,bg=#e9dddb,noreverse]stopped#[default]#[pop-default]]"
        else if (state == "working")
            print " [pi:#[push-default]#[fg=default,bg=#dae5d5,noreverse]working#[default]#[pop-default]]"
        else if (state == "waiting")
            print " [pi:#[push-default]#[fg=default,bg=#e9dddb,noreverse]waiting#[default]#[pop-default]]"
        else if (state == "idle")
            print " [pi:#[push-default]#[fg=default,bg=#f9e2af,noreverse]idle#[default]#[pop-default]]"
        else print ""
    }
'
