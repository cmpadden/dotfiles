#!/usr/bin/env bash

#
# Gets current working Python virtual environemnt including direnv.
#
# Reference(s):
#   https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
#
prompt_venv()
{
    if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
        printf "%s " "$(basename "$VIRTUAL_ENV")"
    fi
}

#
# Gets current working Git branch.
#
# Reference(s):
#   https://www.shellhacks.com/show-git-branch-terminal-command-prompt/
#
prompt_git_branch()
{
    if git rev-parse --git-dir >/dev/null 2>&1; then
        printf "%s " "$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    fi
}

# Applies custom prompt when `xterm-256color` is active (eg. when in tmux)
#
# \e[0;32m\]
# 0 -> foreground (1: foreground bold; 4: foreground underlined, nil: background)
# 2 -> color code
#
# Reference(s):
#  - https://wiki.gentoo.org/wiki/Bash#PS1 for more information
#  - https://wiki.archlinux.org/title/Bash/Prompt_customization
#
if [ "$TERM" == "xterm-256color" ]; then
    PS1='\e[0;32m\]$(prompt_venv)\e[0;34m\]$(prompt_git_branch)\e[0;32m\]\w\n\[\e[0m\]\$ '
fi
