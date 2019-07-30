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

# fzf layout
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# bash completion
if [ -f "$(brew --prefix)/etc/bash_completion" ]; then
    # shellcheck source=/dev/null
    source  "$(brew --prefix)/etc/bash_completion"
fi

# gcloud bash completion
if [[ -d "$(brew --prefix)/Caskroom/google-cloud-sdk" ]]; then
    # shellcheck source=/dev/null
    source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"
    # shellcheck source=/dev/null
    source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"
fi

JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
export JAVA_HOME

# Auto-attach a tmux session
if [ -x "$(command -v tmux)" ]; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then
        # Attach to an existing session, or create a new session
        tmux attach || tmux new-session
    fi
fi
