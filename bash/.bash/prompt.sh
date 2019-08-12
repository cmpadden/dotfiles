#!/usr/bin/env bash

# https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
show_virtual_env() {
  if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
    echo "($(basename "$VIRTUAL_ENV")) "
  fi
}
export -f show_virtual_env

PS1='$(show_virtual_env)'"\w "
