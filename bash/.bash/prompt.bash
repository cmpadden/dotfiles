#!/usr/bin/env bash
#
# Reference(s):
#  - https://wiki.gentoo.org/wiki/Bash#PS1 for more information
#  - https://wiki.archlinux.org/title/Bash/Prompt_customization
#  - https://stackoverflow.com/a/33206814
#  - https://www.shellcheck.net/wiki/SC2025
#  - https://en.wikipedia.org/wiki/Box-drawing_characters

CONF_SHOW_HR=false

# Gets current working Python virtual environemnt including direnv.
#
# Reference(s):
#   https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
#
prompt_venv()
{
    if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
        local version=$(python -V | awk '{print $2}')
        local venv="$(basename "$VIRTUAL_ENV")"
        printf " %s %s " "$venv" "$version"
    fi
}

# Gets current working Git branch.
#
# Reference(s):
#   https://www.shellhacks.com/show-git-branch-terminal-command-prompt/
#
prompt_git_branch()
{
    if git rev-parse --git-dir >/dev/null 2>&1; then
        printf " %s " "$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    fi
}

if [ "$CONF_SHOW_HR" = true ]; then
    PROMPT_COMMAND='printf "\033[0;38;50;48;47%*s\033[0m\n" "${COLUMNS:-$(tput cols)}" "" | tr " " "─"'
fi

if [ "$TERM" == "xterm-256color" ]; then
    PS1='\[\e[48;5;16m\e[K\]'
    PS1+='\[\e[48;5;16m\]\e[38;5;15m\]$(prompt_venv)'
    PS1+='\[\e[48;5;15m\]\e[38;5;16m\]$(prompt_git_branch)\[\e[0m\]'
    PS1+='\[\e[48;5;16m\]\e[38;5;15m\] \w\[\e[0m\]'
    # PS1+='\n▸ '
    PS1+='\n λ '
fi
