#!/usr/bin/env bash

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

if [ -f "$HOME/.config/socket-firewall/env.sh" ]; then
    # shellcheck disable=SC1090
    source "$HOME/.config/socket-firewall/env.sh"
fi

if command -v go >/dev/null 2>&1; then
    export PATH="$(go env GOPATH)/bin:$PATH"
fi
