#!/usr/env bash

# only apply customizations to interactive shells
[[ $- != *i* ]] && return

warn() {
    printf '\e[38;5;0;48;5;226m %s \e[0m %s\n' "WARN" "$1"
}

error() {
    printf '\e[38;5;0;48;5;196m %s \e[0m %s\n' "ERROR" "$1"
}

check_and_source() {
    if [ -f "$1" ]; then
        # shellcheck disable=SC1090
        source "$1"
    else
        warn "$1 does not exist"
    fi
}

check_and_source "$HOME/.bash/aliases.bash"
check_and_source "$HOME/.bash/completion.bash"
check_and_source "$HOME/.bash/colors.bash"
check_and_source "$HOME/.bash/functions.bash"
check_and_source "$HOME/.bash/env.bash"
check_and_source "$HOME/.bash/prompt.bash"
check_and_source "$HOME/.bash/shopt.bash"
check_and_source "$HOME/.bash/darwin.bash"
check_and_source "$HOME/.bash/fzf.bash"
check_and_source "$HOME/.bash/private.bash"

# Auto-attach to a tmux session
if command -v tmux &>/dev/null; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then # Attach to an existing session, or create a new session
        tmux attach || tmux new-session
    fi
else
    warn 'tmux is not installed'
fi

# Hook `direnv` into the shell (https://github.com/direnv/direnv)
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
else
    warn 'direnv is not installed'
fi

# https://wiki.archlinux.org/title/GnuPG#Invalid_IPC_response_and_Inappropriate_ioctl_for_device
GPG_TTY=$(tty)
export GPG_TTY

# rustup
check_and_source "$HOME/.cargo/env"

hash nvim 2>/dev/null && export EDITOR="nvim"
