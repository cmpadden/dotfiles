alias d='ddgr'
alias drmf='docker rmi -f $(docker images -q)'
alias l='ls -alh'
alias venvc='python3 -m virtualenv venv'

# gu shows a list of all developers and the number of commits they've made
alias gu="git shortlog | grep -E '^[^ ]'"