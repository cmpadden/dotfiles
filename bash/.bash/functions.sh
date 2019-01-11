# -------------------------------------------------------------------
# compressed file expander 
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------

ex() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf "$1";;
          *.tar.gz) tar xvzf "$1";;
          *.tar.xz) tar xvJf "$1";;
          *.tar.lzma) tar --lzma xvf "$1";;
          *.bz2) bunzip "$1";;
          *.rar) unrar "$1";;
          *.gz) gunzip "$1";;
          *.tar) tar xvf "$1";;
          *.tbz2) tar xvjf "$1";;
          *.tgz) tar xvzf "$1";;
          *.zip) unzip "$1";;
          *.Z) uncompress "$1";;
          *.7z) 7z x "$1";;
          *.dmg) hdiutul mount "$1";; # mount OS X disk images
          *) echo "'$1' cannot be extracted via >ex<";;
    esac
    else
        echo "'$1' is not a valid file"
    fi
}

# -------------------------------------------------------------------
# shell function to define words
# http://vikros.tumblr.com/post/23750050330/cute-little-function-time
# -------------------------------------------------------------------

define() {
    if [ $# -ge 2 ]; then
        echo "givedef: too many arguments" >&2
        return 1
    else
        curl "dict://dict.org/d:$1"
    fi
}


# -------------------------------------------------------------------
# Attempt all variants of caesar cipher
# https://chris-lamb.co.uk/posts/decrypting-caesar-cipher-using-shell
# -------------------------------------------------------------------
decaesar() {
    for I in $(seq 25); do
        echo "$1" | tr "[:lower:]" "[:upper:]" | tr $(printf "%${I}s" | tr ' ' '.')\A-Z A-ZA-Z
    done
}

# Convert hex to decimal
htod() {
    printf "%d\\n" "$1"
}

# Convert ASCII to hexcode
atoh() {
    python2 -c "print '$1'.encode(\"hex\")"
}

# Convert hexcode to ASCII
htoa() {
    python2 -c "print '$1'.decode(\"hex\")"
}

# Repeat `x` a given number of times
repeatn() {
    python -c "print 'x' * $1"
}

