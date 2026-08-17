# Interactive fzf helpers.

fd() {
    # Change directory with fzf.
    local dir
    dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir"
}

fkill() {
    # Kill a process selected with fzf.
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u "$UID" | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ -n "$pid" ]; then
        kill "-${1:-9}" "$pid"
    fi
}

fgb() {
    # Check out a local or remote Git branch selected with fzf.
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
        branch=$(printf '%s\n' "$branches" | fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
        git checkout "$(printf '%s\n' "$branch" | sed 's/.* //' | sed 's#remotes/[^/]*/##')"
}

fpass() {
    # Copy a password-store entry selected with fzf.
    local stores store
    stores=$(find "$HOME/.password-store/" -name '*.gpg' | sed 's/^.*-store\/\/\(.*\)\.gpg/\1/g')
    store=$(printf '%s\n' "$stores" | fzf +m)
    [ -n "$store" ] && pass -c "$store"
}

fbrew() {
    # Install a Homebrew formula selected with fzf.
    local prog
    prog=$(brew search | fzf +m)
    [ -n "$prog" ] && brew install "$prog"
}

fpy() {
    # Search Python documentation with fzf.
    if [ "$#" -eq 0 ]; then
        echo 'Please provide a pydoc search term...'
        return 1
    fi
    local module
    module=$(pydoc -k "$1" 2>/dev/null | fzf)
    if [ -n "$module" ]; then
        pydoc "$module"
    fi
}
