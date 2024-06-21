#!/bin/bash

if [ "$OS_NAME" = 'Darwin' ]; then
    _log "Setting macOS defaults InitialKeyRepeat, KeyRepeat"
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1

    # https://macos-defaults.com/dock/autohide.html
    -log "Setting macOS defaults for Dock and Menu Bar"
    defaults write com.apple.dock "autohide" -bool "true"
    defaults write com.apple.dock "autohide-time-modifier" -float "0"
    killall Dock

    # https://github.com/yannbertrand/macos-defaults/issues/268
    defaults write NSGlobalDomain _HIHideMenuBar -bool true

    # Prevent "Click on Desktop to reveal wallpaper"
    defaults write com.apple.finder CreateDesktop -bool false
    killall Finder

    if ! /usr/bin/grep -q '/opt/homebrew/bin/bash' /etc/shells; then
        _log 'Adding /opt/homebrew/bin/bash to /etc/shells'
        echo "/opt/homebrew/bin/bash" >> /etc/shells
    fi

    if [ ! "$SHELL" = "/opt/homebrew/bin/bash" ]; then
        _log 'Changing shell to /opt/homebrew/bin/bash'
        echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
        chsh -s /opt/homebrew/bin/bash
    fi
fi
