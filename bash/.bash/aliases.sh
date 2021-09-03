# Docker
alias drmf='docker rmi -f $(docker images -q)'
alias drmp='docker kill $(docker ps -q)'

# Git
alias gs="git status"
alias gd="git diff"
alias gu="git shortlog | /usr/bin/grep -E '^[^ ]'"

# Python
alias venvc='python3 -m virtualenv venv'
alias ipy="python -m IPython --matplotlib"
alias mkpyenv="echo \"layout python-venv python3\" >> .envrc && direnv allow"
alias pydoc='python -m pydoc'

# GCP
alias gcp_project="gcloud info --format='value(config.project)'"

gssh() {
  gcloud beta compute ssh --zone "us-east4-a" "$1" -- -p 8800
}

gscp() {
  gcloud beta compute scp --port 8800 --zone "us-east4-a" "$@"
}

# Vim
if hash nvim 2>/dev/null; then
    alias vim="nvim"
fi

# https://github.com/ogham/exa
if hash exa 2>/dev/null; then
  alias l='exa -1 --group-directories-first'
  alias ls='exa -l --classify --group --time-style long-iso --group-directories-first'
else
  echo "\`exa\` not installed -- falling back to \`ls\`"
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
else
  echo "\`bat\` not installed -- falling back to \`cat\`"
fi


# Alias Neovim to Vim if installed
if hash nvim 2>/dev/null; then
    alias vim="nvim"
fi

# Notes
alias n="cd \${HOME}/workspace/personal-mkdocs/docs/"
alias nv="vim \${HOME}/workspace/personal-mkdocs/docs/"

# Python
alias venvc='python3 -m virtualenv venv'
alias ipy="python -m IPython --matplotlib"

# Rsync
alias rscp='rsync -aP'
alias rsmv='rsync -aP --remove-source-files'

# https://github.com/ggreer/the_silver_searcher
if hash ag 2>/dev/null; then
    alias grep="ag --hidden --ignore .git"
else
  echo "\`ag\` not installed -- falling back to \`grep\`"
fi

