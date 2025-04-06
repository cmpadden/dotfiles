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

FIREFOX_PROFILES_ROOT_DIRECTORY=~/Library/Application\ Support/Firefox/Profiles/

for path in "$FIREFOX_PROFILES_ROOT_DIRECTORY"*; do
    if [ -d "$path" ]; then
        mkdir -p "$path/chrome"
        cat > "$path/chrome/userChrome.css" <<- EOM
/* Hide horizontal tabs at the top of the window #1349 */

#main-window[tabsintitlebar="true"]:not([extradragspace="true"]) #TabsToolbar {
  opacity: 0;
  pointer-events: none;
}

#main-window:not([tabsintitlebar="true"]) #TabsToolbar {
    visibility: collapse !important;
}

/* Hide the "Tree Style Tab" header at the top of the sidebar #1397 */

#sidebar-box[sidebarcommand="treestyletab_piro_sakura_ne_jp-sidebar-action"] #sidebar-header {
  display: none;
}
EOM
    echo "Updated $path/chrome/userChrome.css"
    fi
done






