#!/bin/bash

# Install script for personal machines.

###############################################################################
#                                  Constants                                  #
###############################################################################

# Used to determine which evironment is being configured: 'Darwin' or 'Linux'
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

    # Install core packages and casks (NOTE: one can find a list of top-level
    # packages with `brew leaves`)

    _log "Installing brew packages"
    brew install \
        bash \
        bash-completion \
        bat \
        chatblade \
        cmake \
        curl \
        direnv \
        docker \
        docker-compose \
        exa \
        fd \
        ffmpeg \
        fzf \
        git \
        httpie \
        imagemagick \
        jq \
        neovim \
        node \
        nvm \
        pass \
        pass-otp \
        pdfgrep \
        pre-commit \
        pyenv \
        pyenv-virtualenv \
        ripgrep \
        stow \
        the_silver_searcher \
        tldr \
        tmux \
        watch \
        withgraphite/tap/graphite \
        yarn

    _log "Installing brew casks"
    brew install --cask \
        chromium \
        hammerspoon \
        kitty \
        mpv \
        notion \
        slack \
        spotify \
        zoom

    # brew tap adoptopenjdk/openjdk
    # brew install --cask adoptopenjdk8

    _log "Installing LTS version of Node.js"
    nvm install --lts

    _log "Installing Tmux Plugin Manager"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

    _log "Setting MacOS settings: InitialKeyRepeat, KeyRepeat"
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1

    _log 'NOTE: If Chromium.app fails to open, run `xattr -cr /Applications/Chromium.app`'

fi

###############################################################################
#                                    Linux                                    #
###############################################################################

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
            exa \
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
