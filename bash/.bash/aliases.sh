# -------------------------------------------------------------------
# Directory Movement
# -------------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias bk='cd $OLDPWD'

# -------------------------------------------------------------------
# Directory Information
# -------------------------------------------------------------------

alias l='ls -lh --color'
alias la='ls -alh --color'
alias ls='ls --color'
alias ll='ls -Fahl --color'
alias tree="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'"

# -------------------------------------------------------------------
# Git
# -------------------------------------------------------------------

alias ga='git add'
alias gb='git branch'
alias gc='git checkout'
alias gcb='git checkout -b'
alias gcl='git clone'
alias gd='git diff'
alias gf='git reflog'
alias gl='git log'
alias gm='git commit -m'
alias gma='git commit -am'
alias gp='git push'
alias gpl="git log --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gpu='git pull'
alias gra='git remote add'
alias grr='git remote rm'
alias gs='git status'
alias gta='git tag -a -m'
alias gv='git log --pretty=format:'%s' | cut -d " " -f 1 | sort | uniq -c | sort -nr'

# gu shows a list of all developers and the number of commits they've made
alias gu="git shortlog | grep -E '^[^ ]'"
