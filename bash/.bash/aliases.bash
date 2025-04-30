#!/usr/bin/env bash

####################################################################################################
#                                             General                                              #
####################################################################################################

if hash nvim 2>/dev/null; then
    alias v="nvim"
    alias vim="nvim"
    alias vimdiff="nvim -d"
fi

if [ -f "$HOME/notes.md.asc" ]; then
    alias notes="nvim \$HOME/notes.md.asc"
    alias ns="tmux split-window -h 'nvim \$HOME/notes.md.asc'"
    alias notes-backup='cp "$HOME/notes.md.asc" "$HOME/backups/notes.md.$(date -Iminutes).asc"'
else
    alias notes="nvim ~/src/notes/work/index.md"
    alias scratch="nvim ~/src/notes/work/scratch.md"
fi

alias notes-sync='\
    pushd ~/src/notes && \
    git add . && \
    git status && \
    git commit --allow-empty-message -m "" && \
    git push &&\
    popd'

alias date-short="date +%Y%m%d"

alias rscp='rsync -aP'
alias rsmv='rsync -aP --remove-source-files'

if hash eza 2>/dev/null; then
    alias l='eza -1 --group-directories-first'
    alias ls='eza -l --no-user --time-style long-iso --group-directories-first'
else
    alias l='ls -1p'
    alias ls='ls -lhpG'
fi

if hash rg 2>/dev/null; then
    alias grep="rg --smart-case"
fi


if [ -f ~/Applications/SnowSQL.app/Contents/MacOS/snowsql ]; then
    alias snowsql='~/Applications/SnowSQL.app/Contents/MacOS/snowsql'
fi

alias tar_compress="tar -czvf"
alias tar_extract="tar -xzvf"

# source environment variables in `.env` filtering comments
alias source_env='export $(grep -v ^# .env | xargs)'

####################################################################################################
#                                              Docker                                              #
####################################################################################################

alias docker_remove_images='docker rmi -f $(docker images -q)'
alias docker_kill_all='docker kill $(docker ps -qa)'

####################################################################################################
#                                               Git                                                #
####################################################################################################

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
alias gb="git checkout -b"
alias wip="git commit -m \"wip\" && git push"
alias pr="gh pr checkout"

save() {
    git add .
    git status
    read -r -p "Press Enter to commit changes..."
    git commit --allow-empty-message -m ""
    read -r -p "Press Enter to push changes..."
    git push
}

####################################################################################################
#                                              Python                                              #
####################################################################################################

alias mkpyenv="echo \"layout uv\" > .envrc && direnv allow"
alias pip='uv pip'
alias pipe-dev="pip install -e .[dev]"
alias pydoc='python -m pydoc'

####################################################################################################
#                                                AI                                                #
####################################################################################################

if hash aider 2>/dev/null; then
    alias aider="aider --dark-mode --no-gitignore --model sonnet --thinking-tokens 8k"
fi

if hash chatblade 2>/dev/null; then
    alias gpt_programmer="chatblade -s -i -p programmer --theme github-dark"
fi

if hash uvx 2>/dev/null; then
    alias llm="uvx --with llm-anthropic llm chat -m claude-3.5-haiku"
fi
