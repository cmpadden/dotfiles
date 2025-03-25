#
# Automatically bootstrap your system with dotfiles, package installation, and system configuration.
#

DOTFILES_LOCATION="${DOTFILES_LOCATION:-$HOME/src/dotfiles}"
DOTFILES_INSTALL="${DOTFILES_INSTALL:-1}"
DOTFILES_RESTORE="${DOTFILES_RESTORE:-1}"
DOTFILES_CONFIGURE="${DOTFILES_CONFIGURE:-1}"

####################################################################################################
#                                            UTILITIES                                             #
####################################################################################################

function print_line_delimiter() {
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' '='
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

####################################################################################################
#                                            ENTRYPOINT                                            #
####################################################################################################

print_line_delimiter

cat << EOF
USAGE

    /bin/bash -c "\$(curl -fsSL https://github.com/cmpadden/dotfiles/raw/refs/heads/main/_bootstrap.sh)"

CONFIGURATION

    Environment variables can be overwritten for desired behavior:

    DOTFILES_LOCATION - location where dotfiles are to be stored (default: ~/src/dotfiles)
    DOTFILES_INSTALL - install applications and packages (default: 1)
    DOTFILES_RESTORE - whether to restore dotfiles via \`stow\` (default: 1)
    DOTFILES_CONFIGURE - automatically configure system-wide settings (default: 1)

CURRENT CONFIGURATION VALUES

    DOTFILES_LOCATION=$DOTFILES_LOCATION
    DOTFILES_INSTALL=$DOTFILES_INSTALL
    DOTFILES_RESTORE=$DOTFILES_RESTORE
    DOTFILES_CONFIGURE=$DOTFILES_CONFIGURE

EOF

if ! command -v git > /dev/null 2>&1; then
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

echo "[INFO] ${TARGET_SSH_KEY}.pub has been copied to the clipboard..."
cat "${TARGET_SSH_KEY}.pub" | pbcopy

if [ ! -d "$DOTFILES_LOCATION" ]; then
    git clone git@github.com:cmpadden/dotfiles.git "$DOTFILES_LOCATION"
else
    echo "[INFO] directory $DOTFILES_LOCATION already exists. Skipping Git clone..."
fi

pushd "$DOTFILES_LOCATION" >/dev/null || exit

if prompt_yes_no "Install system packages and applications?"; then
    ./_install.sh
fi

if prompt_yes_no "Restore configuration files?"; then
    ./_restore.sh
fi

if prompt_yes_no "Set system settings?"; then
    ./_configure.sh
fi
