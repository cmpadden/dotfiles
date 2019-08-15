#!/usr/bin/env bash

# https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
prompt_venv() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename "$VIRTUAL_ENV")) "
  fi
}
export -f prompt_venv # required for entering sub-processes

# https://www.shellhacks.com/show-git-branch-terminal-command-prompt/
prompt_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}
export -f prompt_git_branch # required for entering sub-processes

PS1='$(prompt_venv)''$(prompt_git_branch)'"\w "
