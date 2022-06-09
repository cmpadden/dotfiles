#!/usr/bin/env bash

if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        # shellcheck source=/dev/null
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        # shellcheck source=/dev/null
        source /etc/bash_completion
    elif [ -r /usr/share/bash-completion/bash_completion ]; then
        # shellcheck source=/dev/null
        source /usr/share/bash-completion/bash_completion
    elif [ -r /opt/homebrew/etc/profile.d/bash_completion.sh ]; then
        # shellcheck source=/dev/null
        source /opt/homebrew/etc/profile.d/bash_completion.sh
    else
        echo "No bash completion file present on the system"
    fi
fi
