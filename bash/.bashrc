#!/usr/env bash

# only apply customizations to interactive shells
[[ $- != *i* ]] && return

warn() {
    printf '\e[43m %s \e[0m %s\n' "WARNING" "$1"
}

error() {
    printf '\e[41m %s \e[0m %s\n' "ERROR" "$1"
}

check_and_source() {
    if [ -f "$1" ]; then
        source "$1"
    else
        warn "$1 does not exist"
    fi
}

check_and_source "$HOME/.bash/aliases.sh"
check_and_source "$HOME/.bash/completion.sh"
check_and_source "$HOME/.bash/colors.sh"
check_and_source "$HOME/.bash/functions.sh"
check_and_source "$HOME/.bash/env.sh"
check_and_source "$HOME/.bash/prompt.sh"
check_and_source "$HOME/.bash/shopt.sh"
check_and_source "$HOME/.bash/darwin.sh"
check_and_source "$HOME/.bash/private.sh"

# Auto-attach to a tmux session
if command -v tmux &>/dev/null; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then
        # Attach to an existing session, or create a new session
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

# fzf layout
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Use `fd` as a `find` alternative for `fzf` directory traversal
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
else
    warn "fd is not installed"
fi

# use `bat` as a `cat` alternative for `fzf` file preview
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
fi

check_and_source "$HOME/.fzf.bash"

# https://wiki.archlinux.org/title/GnuPG#Invalid_IPC_response_and_Inappropriate_ioctl_for_device
# export GPG_TTY=$(tty)

# rustup
check_and_source "$HOME/.cargo/env"
