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

# gcloud bash completion
if [[ -d '/usr/local/Caskroom/google-cloud-sdk' ]]; then
    source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
    source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'
fi

# Ensure `tmux` is installed
if [ -x "$(command -v tmux)" ]; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then
        # Attach to an existing session, or create a new session
        tmux attach || tmux new-session
    fi
fi