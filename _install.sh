#!/usr/bin/env bash
set -euo pipefail

LINUX_INSTALL_X_WINDOWS="${LINUX_INSTALL_X_WINDOWS:-1}"
LINUX_INSTALL_CORE_APPLICATIONS="${LINUX_INSTALL_CORE_APPLICATIONS:-1}"
LINUX_INSTALL_GRAPHICAL_APPLICATIONS="${LINUX_INSTALL_GRAPHICAL_APPLICATIONS:-1}"
LINUX_INSTALL_NVIDIA_DRIVERS="${LINUX_INSTALL_NVIDIA_DRIVERS:-1}"

OS_NAME=$(uname -s)

# figlet -f rozzo "macos"
MESSAGE_MACOS=$(cat <<'EOM'

888 888 8e   ,"Y88b  e88'888  e88 88e   dP"Y
888 888 88b "8" 888 d888  '8 d888 888b C88b
888 888 888 ,ee 888 Y888   , Y888 888P  Y88D
888 888 888 "88 888  "88,e8'  "88 88"  d,dP

EOM
)

# figlet -f rozzo "linux"
MESSAGE_LINUX=$(cat <<'EOM'

888 ,e,
888  x  888 8e  8888 8888  Y8b Y8Y
888 888 888 88b 8888 8888   Y8b Y
888 888 888 888 Y888 888P  e Y8b
888 888 888 888  "88 88"  d8b Y8b

EOM
)

###############################################################################
#                                   Helpers                                   #
###############################################################################

# Log a message with a timestamp
# Arguments:
#   Message
function _log() {
    message="$1"
    echo "$(date +"%T") - ${message}"
}

function install_tmux_plugin_manager() {
    local target_user=${SUDO_USER:-${USER:-}}
    local target_home=$HOME
    local target_directory

    if [[ $EUID -eq 0 ]]; then
        if [ -z "$target_user" ] || [ "$target_user" = "root" ]; then
            _log "Skipping Tmux Plugin Manager install while running as root"
            return
        fi

        target_home=$(eval echo "~${target_user}")
    fi

    target_directory="${target_home}/.tmux/plugins/tpm"

    if [ ! -d "$target_directory" ]; then
        _log "Installing Tmux Plugin Manager to ${target_directory}"
        if [[ $EUID -eq 0 ]]; then
            sudo -u "$target_user" mkdir -p "$(dirname "$target_directory")"
            sudo -u "$target_user" git clone https://github.com/tmux-plugins/tpm "$target_directory"
        else
            mkdir -p "$(dirname "$target_directory")"
            git clone https://github.com/tmux-plugins/tpm "$target_directory"
        fi
    fi
}

install_tmux_plugin_manager

###############################################################################
#                                    MacOS                                    #
###############################################################################

if [ "$OS_NAME" = 'Darwin' ]; then

    echo "$MESSAGE_MACOS"

    # Install Homewbrew
    if command -v brew >/dev/null; then
        _log "Homebrew is already installed"
    else
        _log "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi

    # Install core packages and casks (NOTE: one can find a list of top-level packages with `brew
    # leaves`)

    _log "Installing brew packages"
    brew install \
        bash \
        bash-completion \
        bat \
        chatblade \
        cmake \
        curl \
        direnv \
        duckdb \
        eza \
        fd \
        ffmpeg \
        figlet \
        fzf \
        gh \
        git \
        httpie \
        imagemagick \
        jq \
        llm \
        neovim \
        nvm \
        openssh \
        pass \
        pass-otp \
        pdfgrep \
        pinentry-mac \
        pnpm \
        pre-commit \
        pyenv \
        pyenv-virtualenv \
        ranger \
        ripgrep \
        sad \
        shfmt \
        stow \
        stylua \
        the_silver_searcher \
        tldr \
        tmux \
        uv \
        watch \
        withgraphite/tap/graphite \
        yarn \
        &>/dev/null

    _log "Installing brew casks"
    brew install --cask \
        firefox \
        ghostty \
        hammerspoon \
        mpv \
        notion \
        notion-calendar \
        slack \
        &>/dev/null

        # spotify \
        # docker \
        # linear-linear \
        # snowflake-snowsql \
        # zoom

    _log "Installing LTS version of Node.js"


    if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
        # shellcheck source=/dev/null
        source "/opt/homebrew/opt/nvm/nvm.sh"
        nvm install --lts
    fi


    if [ ! -d ~/.hammerspoon/Spoons/SpoonInstall.spoon ]; then
        _log 'Installing Hammerspoon SpoonInstall.spoon'
        curl -O -L https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip
        unzip SpoonInstall.spoon.zip
        open SpoonInstall.spoon
    fi

    _log 'NOTE: If Chromium.app fails to open, run: xattr -cr /Applications/Chromium.app'
fi

if [ "$OS_NAME" = 'Linux' ]; then

    echo "$MESSAGE_LINUX"
    if [[ $EUID -ne 0 ]]; then
       _log "This script must be run as root. Run \`sudo ./_install.sh\`." 
       exit 1
    fi

    # Install core packages with `pacman` (NOTE: one can find a list of installed packages using `pacman -Qe`)
    if command -v pacman >/dev/null; then

        _log "Upgrading system packages."
        pacman -Syu --noconfirm >/dev/null

        if [ "$LINUX_INSTALL_CORE_APPLICATIONS" -eq 1 ]; then
            _log "Installing core packages."
            pacman -S --needed --noconfirm \
                bash-completion \
                bat \
                eza \
                fd \
                fzf \
                git \
                jq \
                neovim \
                openssh \
                pass \
                pass-otp \
                ripgrep \
                sensors-detect \
                stow \
                sudo \
                tldr \
                tmux \
                unzip \
                zip \
                2>/dev/null
        fi

        if [ "$LINUX_INSTALL_NVIDIA_DRIVERS" -eq 1 ]; then
            _log "Installing \`nvidia\` drivers."
            # lspci -k -d ::03xx
            pacman -S --needed --noconfirm \
                nvidia \
                >/dev/null 2>&1
        fi

        if [ "$LINUX_INSTALL_X_WINDOWS" -eq 1 ]; then
            _log "Installing X windows."
            pacman -S --needed --noconfirm \
                i3-wm \
                i3status \
                rofi \
                xclip \
                xorg-server \
                xorg-xinit \
                xorg-xset \
                >/dev/null 2>&1
        fi

        if [ "$LINUX_INSTALL_GRAPHICAL_APPLICATIONS" -eq 1 ]; then
            _log "Installing GUI applications."
            pacman -S --needed --noconfirm \
                ghostty \
                firefox \
                >/dev/null 2>&1
        fi

    fi

fi
