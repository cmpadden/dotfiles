case $- in
    *i*) ;;
      *) return;;
esac

source ~/.bash/aliases.sh
source ~/.bash/colors.sh
source ~/.bash/completion.sh
source ~/.bash/functions.sh
source ~/.bash/history.sh
source ~/.bash/prompt.sh
source ~/.bash/shopt.sh

if which tmux >/dev/null 2>&1; then
    test -z "$TMUX" && (tmux attach || tmux -2 new-session)
fi
