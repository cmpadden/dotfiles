#!/usr/bin/env bash
#
# Automatically bootstrap your system with dotfiles, package installation, and system configuration.
#
set -euo pipefail

DOTFILES_LOCATION="${DOTFILES_LOCATION:-$HOME/src/dotfiles}"
DOTFILES_INSTALL="${DOTFILES_INSTALL:-prompt}"
DOTFILES_RESTORE="${DOTFILES_RESTORE:-prompt}"
DOTFILES_CONFIGURE="${DOTFILES_CONFIGURE:-prompt}"

####################################################################################################
#                                            UTILITIES                                             #
####################################################################################################

function print_line_delimiter() {
    local width=${COLUMNS:-80}

    if [ -z "${COLUMNS:-}" ] && command -v tput >/dev/null 2>&1; then
        width=$(tput cols 2>/dev/null || echo 80)
    fi

    printf '%*s\n' "$width" '' | tr ' ' '='
}

function prompt_yes_no() {
    local message=$1
    read -r -e -p "[y/N] ${message}" response
    if [[ "$response" == [Yy]* ]]; then
        return 0
    else
        return 1
    fi
}

function should_run_step() {
    local value=$1
    local message=$2

    case "$value" in
    1 | true | yes | y) return 0 ;;
    0 | false | no | n) return 1 ;;
    prompt) prompt_yes_no "$message" ;;
    *)
        echo "[ERROR] Unsupported value '${value}'. Use 1, 0, or prompt."
        exit 1
        ;;
    esac
}

function copy_public_key() {
    local public_key=$1

    if command -v pbcopy >/dev/null 2>&1; then
        pbcopy <"$public_key"
        echo "[INFO] ${public_key} has been copied to the clipboard..."
    elif command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard <"$public_key"
        echo "[INFO] ${public_key} has been copied to the clipboard..."
    else
        echo "[INFO] Clipboard utility unavailable. Public key:"
        cat "$public_key"
    fi
}

####################################################################################################
#                                            ENTRYPOINT                                            #
####################################################################################################

print_line_delimiter

cat <<EOF
USAGE

    /bin/bash -c "\$(curl -fsSL https://github.com/cmpadden/dotfiles/raw/refs/heads/main/_bootstrap.sh)"

CONFIGURATION

    Environment variables can be overwritten for desired behavior:

    DOTFILES_LOCATION - location where dotfiles are to be stored (default: ~/src/dotfiles)
    DOTFILES_INSTALL - install applications and packages: 1, 0, or prompt (default: prompt)
    DOTFILES_RESTORE - whether to restore dotfiles via \`stow\`: 1, 0, or prompt (default: prompt)
    DOTFILES_CONFIGURE - automatically configure system-wide settings: 1, 0, or prompt (default: prompt)

CURRENT CONFIGURATION VALUES

    DOTFILES_LOCATION=$DOTFILES_LOCATION
    DOTFILES_INSTALL=$DOTFILES_INSTALL
    DOTFILES_RESTORE=$DOTFILES_RESTORE
    DOTFILES_CONFIGURE=$DOTFILES_CONFIGURE

EOF

if ! command -v git >/dev/null 2>&1; then
    echo "Git is not available on this system. Aborting..."
    exit 1
fi

TARGET_SSH_KEY=~/.ssh/id_ed25519

if [ -f "$TARGET_SSH_KEY" ]; then
    echo "[INFO] SSH key ${TARGET_SSH_KEY} already exists; skipping key generation..."
else
    read -p "Enter e-mail address for \`ssh-keygen\`:" email
    ssh-keygen -t ed25519 -C "$email"
fi

copy_public_key "${TARGET_SSH_KEY}.pub"

if [ ! -d "$DOTFILES_LOCATION" ]; then
    git clone git@github.com:cmpadden/dotfiles.git "$DOTFILES_LOCATION"
else
    echo "[INFO] directory $DOTFILES_LOCATION already exists. Skipping Git clone..."
fi

pushd "$DOTFILES_LOCATION" >/dev/null || exit

if should_run_step "$DOTFILES_INSTALL" "Install system packages and applications?"; then
    ./_install.sh
fi

if should_run_step "$DOTFILES_RESTORE" "Restore configuration files?"; then
    ./_restore.sh
fi

if should_run_step "$DOTFILES_CONFIGURE" "Set system settings?"; then
    ./_configure.sh
fi
