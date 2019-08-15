# Docker
alias drmf='docker rmi -f $(docker images -q)'

# Git
alias gs="git status"
alias gu="git shortlog | grep -E '^[^ ]'"

# https://github.com/ogham/exa
if hash exa 2>/dev/null; then
  alias l='exa -1'
else
  alias l='ls -lhp'
fi

# https://github.com/sharkdp/bat
if hash bat 2>/dev/null; then
    alias cat="bat \
        --theme=ansi-light \
        --style header,grid \
        --pager=never \
        --wrap=never"
fi

# Notes
alias n="cd \${HOME}/workspace/personal-mkdocs/docs/"
alias nv="vim \${HOME}/workspace/personal-mkdocs/docs/"

# Python
alias venvc='python3 -m virtualenv venv'
alias ipy="python -m IPython --matplotlib"
