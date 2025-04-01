#!/usr/bin/env bash
#
# REFERENCES
#
#     https://macos-defaults.com/
#

# set -ex

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

defaults write -g InitialKeyRepeat -int 10

defaults write -g KeyRepeat -int 1

defaults write com.apple.dock autohide -bool true

defaults write com.apple.dock autohide-time-modifier -float "0"

defaults write com.apple.dock "orientation" -string "left"

# resize dock (default size: 42)
defaults write com.apple.dock tilesize -int 35

# NOTE: use must log out for these changes to take effect, see:
# https://github.com/yannbertrand/macos-defaults/issues/268
defaults write NSGlobalDomain _HIHideMenuBar -bool true

# Prevent "Click on Desktop to reveal wallpaper"
defaults write com.apple.finder CreateDesktop -bool false

defaults write NSGlobalDomain com.apple.mouse.linear -bool "true"

# TODO - use conditional callback/finally
killall Dock
killall Finder

target_shell='/opt/homebrew/bin/bash'
if ! /usr/bin/grep -q "$target_shell" /etc/shells; then
    echo "[INFO] Adding /opt/homebrew/bin/bash to /etc/shells"
    sudo echo "$target_shell" >> /etc/shells
else
    echo "[INFO] ${target_shell} is already present in /etc/shells"
fi

if [ ! "$SHELL" = "$target_shell" ]; then
    echo "[INFO] setting default shell to ${target_shell} with \`chsh\`"
    echo "/opt/homebrew/bin/bash" | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/bash
else
    echo "[INFO] ${target_shell} is already set in \$SHELL"
fi

# TODO - https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/hide_tabs_toolbar_v2.css
# TODO - toolkit.legacyUserProfileCustomizations.stylesheets
#
# ~/Library/Application Support/Firefox/Profiles/2zcq9a8d.default-release/chrome
# $ ls
# total 8
# -rw-r--r--@ 1 colton  staff   1.5K Dec 12 09:37 userChrome.css


# https://gist.github.com/benjifs/054e00deee252b5bb1b88e7afe590794?permalink_comment_id=4782055#gistcomment-4782055
echo "[INFO] rebinding <caps lock> to <control>"
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' &>/dev/null
