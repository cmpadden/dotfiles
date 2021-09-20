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

# do not allow `pip intall` outside of virtual environments
export PIP_REQUIRE_VIRTUALENV=true


# MacOS Specific Configurations
if [[ "$OSTYPE" =~ ^darwin ]]; then

  # filter `.DS_Store` from bash completion
  export FIGNORE=$FIGNORE:.DS_Store

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

  # See `brew info` for post-installation instructions:
  # sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
  JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
  export JAVA_HOME

fi


# bash completions
if [ -r /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
else
    echo "Missing: /usr/share/bash-completion/bash_completion"
fi

# Auto-attach to a tmux session
# If not running interactively, do not do anything
[[ $- != *i* ]] && return
if [ -x "$(command -v tmux)" ]; then
    # Do not run when already inside of a `tmux` session
    if [ -z "$TMUX" ]; then
        # Attach to an existing session, or create a new session
        tmux attach || tmux new-session
    fi
fi

# Hook `direnv` into the shell (https://github.com/direnv/direnv)
if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook bash)"
fi

# OSX 10.15 SILENCE BASH DEPRECATION MESSAGE
export BASH_SILENCE_DEPRECATION_WARNING=1

# fzf layout
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# use `fd` as a `find` alternative for `fzf` directory traversal
if command -v fd > /dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
fi

# use `bat` as a `cat` alternative for `fzf` file preview
command -v bat  > /dev/null && export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

if [ -d /usr/lib/jvm/java-15-openjdk ]; then
    export JAVA_HOME=/usr/lib/jvm/java-15-openjdk
fi

if [ -d /usr/lib/jvm/java-8-openjdk ]; then
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk/jre
fi

# if [ -d /usr/lib/jvm/java-16-openjdk ]; then
#     export JAVA_HOME=/usr/lib/jvm/java-16-openjdk
# fi

# https://wiki.archlinux.org/title/GnuPG#Invalid_IPC_response_and_Inappropriate_ioctl_for_device
export GPG_TTY=$(tty)
