#!/bin/bash

if [ "$OS_NAME" = 'Darwin' ]; then
    echo "Setting macOS defaults InitialKeyRepeat, KeyRepeat"
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1

    # https://macos-defaults.com/dock/autohide.html
    echo "Setting macOS defaults for Dock and Menu Bar"

    # automatically hide dock
    defaults write com.apple.dock "autohide" -bool "true"

    # disable dock animation
    defaults write com.apple.dock "autohide-time-modifier" -float "0"

    # resize dock (default size: 42)
    defaults write com.apple.dock tilesize -int 35

    # restart dock
    killall Dock

    # https://github.com/yannbertrand/macos-defaults/issues/268
    defaults write NSGlobalDomain _HIHideMenuBar -bool true

    # Prevent "Click on Desktop to reveal wallpaper"
    defaults write com.apple.finder CreateDesktop -bool false
    killall Finder

    if ! /usr/bin/grep -q '/opt/homebrew/bin/bash' /etc/shells; then
        echo 'Adding /opt/homebrew/bin/bash to /etc/shells'
        echo "/opt/homebrew/bin/bash" >> /etc/shells
    fi

    if [ ! "$SHELL" = "/opt/homebrew/bin/bash" ]; then
        echo 'Changing shell to /opt/homebrew/bin/bash'
        echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
        chsh -s /opt/homebrew/bin/bash
    fi
fi
