#!/usr/bin/env bash
#
# Updates Firefox profiles with custom `userChrome.css`.
#
# Requires setting:
#
#       toolkit.legacyUserProfileCustomizations.stylesheets true
#
#       prefs.js
#       312:user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
#

set -euo pipefail

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USER_CHROME_SOURCE="${SCRIPT_DIRECTORY}/firefox/userChrome.css"
FIREFOX_PROFILES_ROOT_DIRECTORY="${HOME}/Library/Application Support/Firefox/Profiles"

if [ ! -f "$USER_CHROME_SOURCE" ]; then
    echo "[ERROR] Missing source file: ${USER_CHROME_SOURCE}"
    exit 1
fi

if [ ! -d "$FIREFOX_PROFILES_ROOT_DIRECTORY" ]; then
    echo "[INFO] Firefox profiles directory does not exist: ${FIREFOX_PROFILES_ROOT_DIRECTORY}"
    exit 0
fi

for path in "${FIREFOX_PROFILES_ROOT_DIRECTORY}"/*; do
    if [ -d "$path" ]; then
        mkdir -p "$path/chrome"
        cp "$USER_CHROME_SOURCE" "$path/chrome/userChrome.css"
        echo "Updated $path/chrome/userChrome.css"
    fi
done

echo
echo "To enable custom userChrome.css styles:"
echo "  1. Open about:config in Firefox."
echo "  2. Search for toolkit.legacyUserProfileCustomizations.stylesheets."
echo "  3. Set the preference to true."
