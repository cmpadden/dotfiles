[[ $- != *i* ]] && return

# shellcheck source=/dev/null
source "$HOME/.bash/aliases.sh"

# shellcheck source=/dev/null
source "$HOME/.bash/completion.sh"

# shellcheck source=/dev/null
source "$HOME/.bash/functions.sh"

# shellcheck source=/dev/null
source "$HOME/.bash/history.sh"

# shellcheck source=/dev/null
source "$HOME/.bash/prompt.sh"

# shellcheck source=/dev/null
source "$HOME/.bash/shopt.sh"

# filter `.DS_Store` from bash completion
export FIGNORE=$FIGNORE:.DS_Store

# set `EDITOR` depending on what is available
PATH_MVIM=$(command -v mvim)
PATH_VI=$(command -v vi)
if [ -n "$PATH_MVIM" ]; then
    export EDITOR="$PATH_MVIM"
else
    export EDITOR="$PATH_VI"
fi
