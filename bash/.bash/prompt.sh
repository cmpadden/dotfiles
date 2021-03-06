#!/usr/bin/env bash

###############################################################################
#                              Helper Functions                               #
###############################################################################


# Get current working virtual environemnt (supporting direnv)
# Arguments:
#  None
# Reference:
#   https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
prompt_venv() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
      printf " %s " "$(basename "$VIRTUAL_ENV")"
  fi
}
export -f prompt_venv # required for entering sub-processes

# Get current working branch
# Arguments:
#   None
# Reference:
#   https://www.shellhacks.com/show-git-branch-terminal-command-prompt/
prompt_git_branch() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    printf " %s " "$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
  fi
}
export -f prompt_git_branch # required for entering sub-processes

# Apply foreground and background colors to string
# Arguments:
#  $1 STRING
#  $2 BACKGROUND_COLOR
#  $3 FOREGROUND_COLOR
apply_colors() {
    # number of arguments will be 2 if string is missing or null
    if [ $# -eq 3 ]; then
      printf "\033[48;05;%s;38;05;%sm%s\033[0m" "$2" "$3" "$1"
    fi
}


###############################################################################
#                              Tacky-ass Prompt                               #
###############################################################################


# Apply custom colors when using a multiplexor, but not the default shell
if [ "$TERM" == "screen-256color" ]; then
  # must be single-quotes for expressions to expand
  PS1='$(apply_colors "$(prompt_venv)" "6" "0")'
  PS1+='$(apply_colors "$(prompt_git_branch)" "30" "0")'
  PS1+='$(apply_colors " $(pwd) " "7" "0")'
  PS1+='\n \$ '
fi
