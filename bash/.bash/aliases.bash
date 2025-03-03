#!/usr/bin/env bash

########################################################################################
#                                        Docker                                        #
########################################################################################

alias docker_remove_images='docker rmi -f $(docker images -q)'
alias docker_kill_all='docker kill $(docker ps -qa)'

######################################################################################## Git                                          #
########################################################################################

alias g="git"

alias ga="git add"
alias gc="git checkout"
alias gs="git status --untracked-files=all ."
alias gd="git diff"
alias gds="git diff --staged"
alias gu="git shortlog | /usr/bin/grep -E '^[^ ]'"
alias gfm="git fetch origin main:main"
alias git_delete_merged="git branch --merged | grep -v 'main|master|develop' | xargs git branch -d"
alias git_branch_dates="git for-each-ref --sort=-committerdate --format='%(committerdate:relative) - %(refname:short)' refs/heads/"
alias gcm="git checkout main"
alias gpm="git pull origin main"
alias gcma="git checkout master"
alias gpma="git pull origin master"
alias gcb="git checkout -b"
alias gcp="git checkout -"

save() {
    git add .
    git status
    read -r -p "Press Enter to commit changes..."
    git commit --allow-empty-message -m ""
    read -r -p "Press Enter to push changes..."
    git push
}

alias wip="git commit -m \"wip\" && git push"
alias pr="gh pr checkout"

########################################################################################
#                                       General                                        #
########################################################################################

# vim
if hash nvim 2>/dev/null; then
    alias v="nvim"
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

# notes
if [ -f "$HOME/notes.md.asc" ]; then
    alias notes="nvim \$HOME/notes.md.asc"
    alias ns="tmux split-window -h 'nvim \$HOME/notes.md.asc'"
    alias notes_backup='cp "$HOME/notes.md.asc" "$HOME/backups/notes.md.$(date -Iminutes).asc"'
else
    alias notes="nvim ~/src/notes/work/index.md"
fi

alias notes_sync='\
    pushd ~/src/notes && \
    git add . && \
    git status && \
    git commit --allow-empty-message -m "" && \
    git push &&\
    popd'

alias date_short="date +%Y%m%d"

# rsync
alias rscp='rsync -aP'
alias rsmv='rsync -aP --remove-source-files'

if hash eza 2>/dev/null; then
    alias l='eza -1 --group-directories-first'
    alias ls='eza -l --classify --group --time-style long-iso --group-directories-first'
else
    alias l='ls -1p'
    alias ls='ls -lhpG'
fi

# # https://github.com/sharkdp/bat
# if hash bat 2>/dev/null; then
#     alias cat="bat \
#         --theme=ansi \
#         --style header,grid \
#         --pager=never \
#         --wrap=never"
# fi

# # https://github.com/ggreer/the_silver_searcher
# if hash ag 2>/dev/null; then
#     alias grep="ag --hidden --ignore .git --ignore node_modules --ignore dist --ignore .direnv"
# fi

if hash rg 2>/dev/null; then
    alias grep="rg --smart-case"
fi

# if hash ranger 2>/dev/null; then
#     alias r="ranger"
# fi

# source environment variables in `.env`                                                    │
alias source_env='export $(xargs < .env)'

########################################################################################
#                                        Python                                        #
########################################################################################

alias mkpyenv="echo \"layout pyenv 3.11.7 \" > .envrc && direnv allow"
alias pip='uv pip'
alias pip-dev="pip install -e .[dev]"
alias pydoc='python -m pydoc'
alias ipy="ipython"

########################################################################################
#                                     Google Cloud                                     #
########################################################################################

# google cloud platform
alias gcp_project="gcloud info --format='value(config.project)'"

# snowflake
if [ -f ~/Applications/SnowSQL.app/Contents/MacOS/snowsql ]; then
    alias snowsql='~/Applications/SnowSQL.app/Contents/MacOS/snowsql'
fi

if hash chatblade 2>/dev/null; then
    alias gpt_programmer="chatblade -s -i -p programmer --theme github-dark"
fi

########################################################################################
#                                        MacOS                                         #
########################################################################################

alias books_library="cd ~/Library/Mobile\ Documents/iCloud~com~apple~iBooks/Documents/"
alias taio="cd ~/Library/Mobile\ Documents/iCloud~app~cyan~taio/Documents"

########################################################################################
#                                        Kitty                                         #
########################################################################################

alias icat="kitty +kitten icat"

####################################################################################################
#                                               Misc                                               #
####################################################################################################

alias tar_compress="tar -czvf"
alias tar_extract="tar -xzvf"
