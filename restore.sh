#!/usr/bin/env bash
# shellcheck disable=SC1004

ASCII_STOW='
 ________  _________  ________  ___       __
|\   ____\|\___   ___\\   __  \|\  \     |\  \
\ \  \___|\|___ \  \_\ \  \|\  \ \  \    \ \  \
 \ \_____  \   \ \  \ \ \  \\\  \ \  \  __\ \  \
  \|____|\  \   \ \  \ \ \  \\\  \ \  \|\__\_\  \
    ____\_\  \   \ \__\ \ \_______\ \____________\
   |\_________\   \|__|  \|_______|\|____________|
   \|_________|
'

echo "$ASCII_STOW"

for file in *; do
    if [ -d "$file" ]; then
        read -r -e -p "[y/N] - Restore ${file}? " response
        if [[ "$response" == [Yy]* ]]; then
            stow -t "$HOME" "$file"
        fi
    fi
done

# NOTE: to un-stow a directory, run `stow -t "$HOME" -D tmux`
