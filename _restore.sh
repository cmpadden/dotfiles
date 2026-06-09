#!/usr/bin/env bash
# shellcheck disable=SC1004
set -euo pipefail

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

if ! command -v stow >/dev/null 2>&1; then
    echo "[ERROR] GNU Stow is required. Run ./_install.sh first."
    exit 1
fi

for file in *; do
    # Top-level directories prefixed with '_' are archival and not stow targets.
    if [[ "$file" == _* ]]; then
        continue
    fi

    if [ -d "$file" ]; then
        read -r -e -p "[y/N] - Restore ${file}? " response
        if [[ "$response" == [Yy]* ]]; then
            if stow -n -v -t "$HOME" "$file"; then
                stow -v -t "$HOME" "$file"
            else
                echo "[ERROR] Stow dry-run failed for ${file}; skipping."
            fi
        fi
    fi
done

# NOTE: to un-stow a directory, run `stow -t "$HOME" -D tmux`
