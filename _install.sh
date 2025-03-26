#!/bin/bash

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

###############################################################################
#                                    MacOS                                    #
###############################################################################

if [ "$OS_NAME" = 'Darwin' ]; then

    # echo "$_message_macos"

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

    if [ ! -d ~/.tmux/plugins/tpm ]; then
        _log "Installing Tmux Plugin Manager"
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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

    # echo "$_message_linux"

    # Install core packages with `pacman` (NOTE: one can find a list of installed packages using `pacman -Qe`)

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
