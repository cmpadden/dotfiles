#!/usr/bin/env bash
# shellcheck disable=SC1004

ASCII_STOW='
      ___           ___           ___           ___
     /\  \         /\  \         /\  \         /\__\
    /::\  \        \:\  \       /::\  \       /:/ _/_
   /:/\ \  \        \:\  \     /:/\:\  \     /:/ /\__\
  _\:\~\ \  \       /::\  \   /:/  \:\  \   /:/ /:/ _/_
 /\ \:\ \ \__\     /:/\:\__\ /:/__/ \:\__\ /:/_/:/ /\__\
 \:\ \:\ \/__/    /:/  \/__/ \:\  \ /:/  / \:\/:/ /:/  /
  \:\ \:\__\     /:/  /       \:\  /:/  /   \::/_/:/  /
   \:\/:/  /     \/__/         \:\/:/  /     \:\/:/  /
    \::/  /                     \::/  /       \::/  /
     \/__/                       \/__/         \/__/

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
