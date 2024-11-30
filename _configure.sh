#!/bin/bash
#
# REFERENCES
#
#     https://macos-defaults.com/
#

set -ex

# figlet -f rozzo "Configure"
cat <<EOF

  e88'Y88                    dP,e, ,e,
 d888  'Y  e88 88e  888 8e   8b "   "   e88 888 8888 8888 888,8,  ,e e,
C8888     d888 888b 888 88b 888888 888 d888 888 8888 8888 888 "  d88 88b
 Y888  ,d Y888 888P 888 888  888   888 Y888 888 Y888 888P 888    888   ,
  "88,d88  "88 88"  888 888  888   888  "88 888  "88 88"  888     "YeeP"
                                         ,  88P
                                        "8",P"
EOF

if [[ ! "$OSTYPE" = 'darwin'* ]]; then
    exit
fi

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

# NOTE: use must log out for these changes to take effect, see:
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

# default to show function keys in touch bar
if [ ! "functionKeys" = $(defaults read com.apple.touchbar.agent PresentationModeGlobal) ]; then
    defaults write com.apple.touchbar.agent PresentationModeGlobal functionKeys
    pkill "Touch Bar agent"; killall "ControlStrip";
fi

if [ ! "$SHELL" = "/opt/homebrew/bin/bash" ]; then
    echo 'Changing shell to /opt/homebrew/bin/bash'
    echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/bash
fi

# TODO - use conditional callback/finally
killall Dock
killall Finder
