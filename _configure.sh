#!/usr/bin/env bash
#
# REFERENCES
#
#     https://macos-defaults.com/
#

set -euo pipefail

OS_NAME=$(uname -s)
DOTFILES_WALLPAPER_COLOR="${DOTFILES_WALLPAPER_COLOR:-#005959}"
DOTFILES_WALLPAPER_PATH="${DOTFILES_WALLPAPER_PATH:-$HOME/Pictures/dotfiles/wallpaper.png}"

function load_homebrew_environment() {
    if command -v brew >/dev/null 2>&1; then
        return
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

function configure_linux_dark_mode() {
    echo "[INFO] configuring Linux dark mode defaults"

    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
        dbus-update-activation-environment --systemd \
            GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc \
            || true
    fi

    echo "[INFO] restart the graphical session for all applications to inherit dark mode defaults"
}

function configure_macos_wallpaper() {
    local wallpaper_path=$1
    local wallpaper_color=$2

    if ! command -v magick >/dev/null 2>&1; then
        echo "[INFO] ImageMagick is required to generate a solid-color wallpaper; skipping wallpaper setup"
        return
    fi

    mkdir -p "$(dirname "$wallpaper_path")"
    magick -size 1x1 "xc:${wallpaper_color}" "$wallpaper_path"

    osascript - "$wallpaper_path" <<'APPLESCRIPT'
on run argv
    set wallpaperPath to POSIX file (item 1 of argv)
    tell application "System Events"
        set picture of every desktop to wallpaperPath
    end tell
end run
APPLESCRIPT

    echo "[INFO] set macOS desktop wallpaper color to ${wallpaper_color}"
    echo "[INFO] macOS uses the user desktop wallpaper for the locked-session background"
}

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

if [ "$OS_NAME" = 'Linux' ]; then
    configure_linux_dark_mode
    exit 0
fi

if [ ! "$OS_NAME" = 'Darwin' ]; then
    echo "[INFO] unsupported operating system: ${OS_NAME}"
    exit 0
fi

load_homebrew_environment

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

configure_macos_wallpaper "$DOTFILES_WALLPAPER_PATH" "$DOTFILES_WALLPAPER_COLOR"

# TODO - use conditional callback/finally
killall Dock || true
killall Finder || true

if ! command -v brew >/dev/null 2>&1; then
    echo "[INFO] Homebrew is required to configure the default bash shell; skipping shell setup"
else
    target_shell="$(brew --prefix)/bin/bash"
    target_user="${SUDO_USER:-${USER:-}}"
    target_user_record="/Users/${target_user}"
    current_shell="$(dscl . -read "$target_user_record" UserShell 2>/dev/null | awk '{print $2}' || true)"

    if ! /usr/bin/grep -qxF "$target_shell" /etc/shells; then
        echo "[INFO] Adding ${target_shell} to /etc/shells"
        echo "$target_shell" | sudo tee -a /etc/shells >/dev/null
    else
        echo "[INFO] ${target_shell} is already present in /etc/shells"
    fi

    if [ ! "$current_shell" = "$target_shell" ]; then
        echo "[INFO] setting default shell for ${target_user} to ${target_shell} with \`chsh\`"
        chsh -s "$target_shell" "$target_user"

        current_shell="$(dscl . -read "$target_user_record" UserShell 2>/dev/null | awk '{print $2}' || true)"
        if [ ! "$current_shell" = "$target_shell" ]; then
            echo "[ERROR] Login shell is still ${current_shell:-unknown}; expected ${target_shell}."
            echo "[INFO] Try running manually: chsh -s ${target_shell} ${target_user}"
            exit 1
        fi
    else
        echo "[INFO] ${target_shell} is already set as the login shell"
    fi
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
