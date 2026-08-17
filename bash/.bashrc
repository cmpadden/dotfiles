#!/usr/bin/env bash

# Keep profile-safe environment available when `.bashrc` is sourced directly.
[[ -f "$HOME/.bash/profile" ]] && source "$HOME/.bash/profile"

# only apply customizations on interactive shells
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

source_if_exists() {
    [ -f "$1" ] || return 0
    # shellcheck disable=SC1090
    source "$1"
}

# Load paths and platform setup before checking which tools are available.
check_and_source "$HOME/.bash/env"
check_and_source "$HOME/.bash/darwin"
check_and_source "$HOME/.bash/shopt"
check_and_source "$HOME/.bash/completion"
check_and_source "$HOME/.bash/colors"
check_and_source "$HOME/.bash/fzf"
check_and_source "$HOME/.bash/fzf-functions"
check_and_source "$HOME/.bash/aliases"
check_and_source "$HOME/.bash/functions"
check_and_source "$HOME/.bash/git"
if command -v wt >/dev/null 2>&1; then
    check_and_source "$HOME/.bash/worktrunk"
fi
check_and_source "$HOME/.bash/bindings"
check_and_source "$HOME/.bash/prompt"
source_if_exists "$HOME/.bash/private"

# Auto-attach to a tmux session
if command -v tmux &>/dev/null; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then # Attach to an existing session, or create a new session
        tmux attach || tmux new-session
    fi
fi

# Hook `direnv` into the shell (https://github.com/direnv/direnv)
if command -v direnv &>/dev/null; then
    eval "$(direnv hook bash)"
fi

# https://wiki.archlinux.org/title/GnuPG#Invalid_IPC_response_and_Inappropriate_ioctl_for_device
GPG_TTY=$(tty)
export GPG_TTY

# # rustup
# check_and_source "$HOME/.cargo/env"

hash nvim 2>/dev/null && export EDITOR="nvim"
