# fzf layout
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# Use `fd` as a `find` alternative for `fzf` directory traversal
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
else
    warn "fd is not installed"
fi

# use `bat` as a `cat` alternative for `fzf` file preview
if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}'"
fi

# override fzf shell expansion (eg. **<tab>)
#
# https://github.com/junegunn/fzf?tab=readme-ov-file#settings
#
# declare -f _fzf_compgen_path
_fzf_compgen_path ()
{
    echo "$1";
    command find -L "$1" -name ./*.pyc -prune -o -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) -a -not -path "$1" -print 2> /dev/null | command sed 's@^\./@@'
}

# shellcheck source=/dev/null
hash fzf 2>/dev/null && eval "$(fzf --bash)"
