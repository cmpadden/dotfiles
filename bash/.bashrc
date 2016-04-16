#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompts
PS1="[\t \u@\h:\w ] $ "

# Aliases
alias l='ls --color=auto'
alias ll='ls -alh --color=auto'
alias ls='ls --color=auto'

# Binds
# History Completion
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Path
if which ruby >/dev/null && which gem >/dev/null; then
  PATH="$(ruby -rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
