#!/usr/bin/env bash

# docker
alias drmf='docker rmi -f $(docker images -q)'
alias drmp='docker kill $(docker ps -q)'

########################################################################################
#                                         Git                                          #
########################################################################################

alias g="git"

alias gs="git add"
alias gc="git checkout"
alias gs="git status ."
alias gd="git diff"
alias gu="git shortlog | /usr/bin/grep -E '^[^ ]'"
alias git_delete_merged="git branch --merged | grep -v 'main|master|develop' | xargs git branch -d"

alias gcm="git checkout main"
alias gpm="git pull origin main"
alias gcb="git checkout -b"

########################################################################################
#                                        Python                                        #
########################################################################################

alias venvc='python3 -m virtualenv venv'
alias ipy="python -m IPython --matplotlib"
alias mkpyenv="echo \"layout pyenv 3.9.13 \" > .envrc && direnv allow"
alias pydoc='python -m pydoc'

########################################################################################
#                                      JavaScript                                      #
########################################################################################

alias npm="pnpm"

# google cloud platform
alias gcp_project="gcloud info --format='value(config.project)'"

# vim
if hash nvim 2>/dev/null; then
    alias vim="nvim"
    alias v="nvim"
fi

# rsync
alias rscp='rsync -aP'
alias rsmv='rsync -aP --remove-source-files'

# https://github.com/ogham/exa
if hash exa 2>/dev/null; then
    alias l='exa -1 --group-directories-first'
    alias ls='exa -l --classify --group --time-style long-iso --group-directories-first'
else
    alias l='ls -1p'
    alias ls='ls -lhpG'
fi

# https://github.com/sharkdp/bat
if hash bat 2>/dev/null; then
    alias cat="bat \
        --theme=ansi \
        --style header,grid \
        --pager=never \
        --wrap=never"
fi

# https://github.com/ggreer/the_silver_searcher
if hash ag 2>/dev/null; then
    alias grep="ag --hidden --ignore .git --ignore node_modules --ignore dist"
fi

# snowflake
if [ -f /Applications/SnowSQL.app/Contents/MacOS/snowsql ]; then
    alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql
fi

# notes
if [ -f "$HOME/notes.md.asc" ]; then
    alias notes="nvim \$HOME/notes.md.asc"
    alias ns="tmux split-window -h 'nvim \$HOME/notes.md.asc'"
    alias notes_backup='cp "$HOME/notes.md.asc" "$HOME/backups/notes.md.$(date -Iminutes).asc"'
fi

alias d="date +%Y%m%d"
