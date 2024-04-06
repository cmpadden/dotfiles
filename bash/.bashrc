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
GPG_TTY=$(tty)
export GPG_TTY

# rustup
check_and_source "$HOME/.cargo/env"

if hash nvim 2>/dev/null; then
    export EDITOR="nvim"
fi

# override fzf shell expansion (eg. **<tab>)
#
# https://github.com/junegunn/fzf?tab=readme-ov-file#settings
#
# declare -f _fzf_compgen_path
_fzf_compgen_path ()
{
    echo "$1";
    command find -L "$1" -name ./*.pyc -prune -o -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) -a -not -path "$1" -print 2> /dev/null | command sed 's@^\./@@'
}

# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
