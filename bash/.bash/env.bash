#!/usr/bin/env bash

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# do not allow `pip intall` outside of virtual environments
export PIP_REQUIRE_VIRTUALENV=true

if [ "$(uname -s)" = 'Linux' ]; then
    export GTK_THEME=Adwaita:dark
    export GTK2_RC_FILES=/usr/share/themes/Adwaita-dark/gtk-2.0/gtkrc
    export XDG_CURRENT_DESKTOP=sway
fi
