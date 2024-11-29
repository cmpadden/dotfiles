#!/bin/bash
#
# REFERENCES
#
#     https://macos-defaults.com/dock/autohide.html
#

set -e
set -x

if [[ "$OSTYPE" = 'darwin'* ]]; then

    if [ ! '10' = $(defaults read -g InitialKeyRepeat) ]; then
        defaults write -g InitialKeyRepeat -int 10
    fi

    if [ ! '1' = $(defaults read -g KeyRepeat) ]; then
        defaults write -g KeyRepeat -int 1
    fi

    # automatically hide dock
    if [ '0' = $(defaults read com.apple.dock autohide) ]; then
        defaults write com.apple.dock autohide -bool true
    fi

    # disable dock animation
    if [ ! '0' = $(defaults read com.apple.dock autohide-time-modifier) ]; then
        defaults write com.apple.dock autohide-time-modifier -float "0"
    fi

    # resize dock (default size: 42)
    if [ ! '35' = $(defaults read com.apple.dock tilesize) ]; then
        defaults write com.apple.dock tilesize -int 35
    fi

    # https://github.com/yannbertrand/macos-defaults/issues/268
    if [ '0' = $(defaults read NSGlobalDomain _HIHideMenuBar) ]; then
        defaults write NSGlobalDomain _HIHideMenuBar -bool true
    fi

    # Prevent "Click on Desktop to reveal wallpaper"
    if [ '1' = $(defaults read com.apple.finder CreateDesktop) ]; then
        defaults write com.apple.finder CreateDesktop -bool false
    fi

    if ! /usr/bin/grep -q '/opt/homebrew/bin/bash' /etc/shells; then
        echo 'Adding /opt/homebrew/bin/bash to /etc/shells'
        echo "/opt/homebrew/bin/bash" >> /etc/shells
    fi

    if [ ! "$SHELL" = "/opt/homebrew/bin/bash" ]; then
        echo 'Changing shell to /opt/homebrew/bin/bash'
        echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
        chsh -s /opt/homebrew/bin/bash
    fi

    # TODO - use conditional callback/finally
    killall Dock
    killall Finder
fi
