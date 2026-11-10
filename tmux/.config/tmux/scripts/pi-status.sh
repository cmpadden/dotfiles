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
            print " [pi:#[push-default]#[fg=black,bg=#f9e2af,noreverse]requires-attention#[default]#[pop-default]]"
        else if (best) printf " [pi:%s]\n", state
        else print ""
    }
'
