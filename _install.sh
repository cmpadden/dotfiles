#!/bin/bash

OS_NAME=$(uname -s)

# ASCII font generated with `figlet -f isometric1 MacOS`
# shellcheck disable=SC1004
ASCII_MACOS='
      ___           ___           ___           ___           ___
     /\__\         /\  \         /\  \         /\  \         /\  \
    /::|  |       /::\  \       /::\  \       /::\  \       /::\  \
   /:|:|  |      /:/\:\  \     /:/\:\  \     /:/\:\  \     /:/\ \  \
  /:/|:|__|__   /::\~\:\  \   /:/  \:\  \   /:/  \:\  \   _\:\~\ \  \
 /:/ |::::\__\ /:/\:\ \:\__\ /:/__/ \:\__\ /:/__/ \:\__\ /\ \:\ \ \__\
 \/__/~~/:/  / \/__\:\/:/  / \:\  \  \/__/ \:\  \ /:/  / \:\ \:\ \/__/
       /:/  /       \::/  /   \:\  \        \:\  /:/  /   \:\ \:\__\
      /:/  /        /:/  /     \:\  \        \:\/:/  /     \:\/:/  /
     /:/  /        /:/  /       \:\__\        \::/  /       \::/  /
     \/__/         \/__/         \/__/         \/__/         \/__/
'

# ASCII font generated with `figlet -f isometric1 Linux`
# shellcheck disable=SC1004
ASCII_LINUX='
      ___                   ___           ___           ___
     /\__\      ___        /\__\         /\__\         |\__\
    /:/  /     /\  \      /::|  |       /:/  /         |:|  |
   /:/  /      \:\  \    /:|:|  |      /:/  /          |:|  |
  /:/  /       /::\__\  /:/|:|  |__   /:/  /  ___      |:|__|__
 /:/__/     __/:/\/__/ /:/ |:| /\__\ /:/__/  /\__\ ____/::::\__\
 \:\  \    /\/:/  /    \/__|:|/:/  / \:\  \ /:/  / \::::/~~/~
  \:\  \   \::/__/         |:/:/  /   \:\  /:/  /   ~~|:|~~|
   \:\  \   \:\__\         |::/  /     \:\/:/  /      |:|  |
    \:\__\   \/__/         /:/  /       \::/  /       |:|  |
     \/__/                 \/__/         \/__/         \|__|
'

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

###############################################################################
#                                    MacOS                                    #
###############################################################################

if [ "$OS_NAME" = 'Darwin' ]; then

    echo "$ASCII_MACOS"

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
        node \
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
        shfmt \
        stow \
        stylua \
        the_silver_searcher \
        tldr \
        tmux \
        watch \
        withgraphite/tap/graphite \
        yarn \
        uv

    _log "Installing brew casks"
    brew install --cask \
        docker \
        hammerspoon \
        kitty \
        linear-linear \
        mpv \
        notion \
        notion notion-calendar \
        slack \
        snowflake-snowsql \
        spotify \
        zoom

    _log "Installing LTS version of Node.js"
    nvm install --lts

    _log "Installing Tmux Plugin Manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    # NOTE: this threw an error
    if [ ! -f ~/.hammerspoon/Spoons/SpoonInstall.spoon ]; then
        _log 'Installing Hammerspoon SpoonInstall.spoon'
        curl -O -L https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip
        unzip SpoonInstall.spoon.zip
        open SpoonInstall.spoon
    fi

    _log 'NOTE: If Chromium.app fails to open, run: xattr -cr /Applications/Chromium.app'
fi

if [ "$OS_NAME" = 'Linux' ]; then

    echo "$ASCII_LINUX"

    # Install core packages with `pacman` (NOTE: one can find a list of
    # installed packages using `pacman -Qe`)

    if command -v pacman >/dev/null; then

        _log "Refreshing and upgrading system via Pacman"
        sudo pacman -Syu --noconfirm >/dev/null

        _log "Installing packages via pacman"
        sudo pacman -S --noconfirm \
            bash-completion \
            bat \
            eza \
            fd \
            fzf \
            git \
            jq \
            neovim \
            openssh \
            stow \
            sudo \
            the_silver_searcher \
            tldr \
            tmux \
            unzip \
            zip \
            &>/dev/null

    fi

fi
