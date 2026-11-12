#!/bin/sh

# tmux caches #() output while this job refreshes, keeping pane scans out of
# status-line format expansion. Use IDs and an explicit socket for any server.
[ "$#" -eq 2 ] || exit 1
panes=$(tmux -S "$1" list-panes -t "$2" -F '#{@pi_status} #{@pi_status_until}' 2>/dev/null) || exit 1

printf '%s\n' "$panes" | awk -v now="$(date +%s)" '
    BEGIN {
        label["working"] = "running"
        label["done"] = "stopped"
        label["waiting"] = "waiting"
        label["idle"] = "idle"
        color["working"] = "#dae5d5"
        color["done"] = color["waiting"] = "#e9dddb"
        color["idle"] = "#f9e2af"
    }
    NF == 2 && $2 ~ /^[0-9]+$/ && $2 > now && $1 in label {
        printf "%s#[push-default]#[fg=default,bg=%s,noreverse]π:%s#[default]#[pop-default]", \
            (count++ ? " " : " ["), color[$1], label[$1]
    }
    END {
        # A blank line explicitly clears a previously cached badge.
        print (count ? "]" : "")
    }
'
