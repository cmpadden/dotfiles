#!/usr/bin/env bash

extract() {
    # compressed file expander
    # https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh
    if [[ -f $1 ]]; then
        case $1 in
        *.tar.bz2) tar xvjf "$1" ;;
        *.tar.gz) tar xvzf "$1" ;;
        *.tar.xz) tar xvJf "$1" ;;
        *.tar.lzma) tar --lzma xvf "$1" ;;
        *.bz2) bzip2 -d "$1" ;;
        *.rar) unrar "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xvf "$1" ;;
        *.tbz2) tar xvjf "$1" ;;
        *.tgz) tar xvzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *.dmg) hdiutul mount "$1" ;; # mount OS X disk images
        *) echo "'$1' cannot be extracted via >ex<" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

define() {
    # define words
    # http://vikros.tumblr.com/post/23750050330/cute-little-function-time
    if [ $# -ge 2 ]; then
        echo "givedef: too many arguments" >&2
        return 1
    else
        curl "dict://dict.org/d:$1" | less
    fi
}

decaesar() {
    # all caesar cipher variations
    python3 <<EOF
import string
for i in range(26):
    print(
        "".join(
            [
                string.ascii_uppercase[(ord(c) + i) % 26] if c != " " else " "
                for c in "$1".upper()
            ]
        )
    )
EOF
}

htod() {
    # convert hex to decimal
    printf "%d\\n" "$1"
}

atoh() {
    # convert ASCII to hexcode
    python2 -c "print '$1'.encode(\"hex\")"
}

htoa() {
    # convert hexcode to ASCII
    python2 -c "print '$1'.decode(\"hex\")"
}

repeatn() {
    # repeat `x` `n` number of times
    python -c "print 'x' * $1"
}

java_decompile() {
    # java decompile using binary included with IntelliJ

    if [ ! "$#" -eq 2 ]; then
        echo "Usage: java_decompile <source file> <destination directory>"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "File does not exist: $1"
        return 1
    fi

    if [ ! -d "$2" ]; then
        echo "Directory does not exist: $2"
        return 1
    fi

    java -cp \
        /Applications/IntelliJ\ IDEA\ CE.app/Contents/plugins/java-decompiler/lib/java-decompiler.jar \
        org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler "$1" "$2"
}

notify() {
    # MacOS notifications (useful for things like sleep 5 && notify)
    local title="Shell Notification"
    local text="!"
    if [ "$#" -eq 1 ]; then
        text="$1"
    elif [ "$#" -eq 2 ]; then
        title="$1"
        text="$2"
    fi
    osascript -e "display notification \"$text\" with title \"$title\""
}

serve() {
    # File server with SSL

    openssl req \
        -new \
        -newkey rsa:4096 \
        -days 365 \
        -nodes \
        -x509 \
        -subj "/C=US/ST=DC/L=Washington/O=Tmp/CN=localhost" \
        -keyout localhost.key \
        -out localhost.cert

    python3 <<EOF
from http.server import HTTPServer, BaseHTTPRequestHandler, SimpleHTTPRequestHandler
import ssl

host = 'localhost'
port = 4443

httpd = HTTPServer((host, port), SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket (httpd.socket,
        keyfile='localhost.key',
        certfile='localhost.cert', server_side=True)

print(f"Hosting Files on https://{host}:{port}")

httpd.serve_forever()
EOF

}

fd() {
    # FZF change directories
    local dir
    dir=$(find "${1:-.}" -type d 2>/dev/null | fzf +m) && cd "$dir" || exit
}

fkill() {
    # FZF kill process
    local pid
    if [ "$UID" != "0" ]; then
        pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
    else
        pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    fi

    if [ "x$pid" != "x" ]; then
        echo "$pid" | xargs kill "-${1:-9}"
    fi
}

fgb() {
    # FZF checkout git branches, w/ remote branches
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" | fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
        git checkout "$(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
}

fpass() {
    # FZF password-store
    local stores store
    stores=$(find "$HOME/.password-store/" -name "*.gpg" | sed 's/^.*-store\/\/\(.*\)\.gpg/\1/g')
    store=$(echo "$stores" | fzf +m)
    pass -c "$store"
}

fbrew() {
    # FZF homebrew
    local prog
    prog=$(brew search | fzf +m)
    echo "$prog"
    if [ -n "$prog" ]; then
        brew install "$prog"
    fi
}

color_codes() {
    for i in {0..255}; do
        printf "%3d \x1b[48;5;%sm   \e[0m " "$i" "$i"
        if (((i + 1) % 8 == 0)); then
            printf "\n"
        fi
    done
}

# https://jdhao.github.io/2018/10/19/tmux_nvim_true_color/#verifying
true_color_test() {
    awk 'BEGIN{
    s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
    for (colnum = 0; colnum<77; colnum++) {
        r = 255-(colnum*255/76);
        g = (colnum*510/76);
        b = (colnum*255/76);
        if (g>255) g = 510-g;
        printf "\033[48;2;%d;%d;%dm", r,g,b;
        printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
        printf "%s\033[0m", substr(s,colnum+1,1);
    }
    printf "\n";
    }'
}

fpy() {
    # fzf for search pydocs
    if [[ "$#" == 0 ]]; then
        echo "Please provide a pydoc search term..."
        return 1
    fi
    local module
    module=$(pydoc -k "$1" 2>/dev/null | fzf)
    if [[ -n $module ]]; then
        pydoc "$module"
    fi
}

color_square() {
    if [[ "$#" == 0 ]]; then
        echo "Provide hex color code"
        return 1
    fi
    convert -size 300x300 xc:"$1" "300x00_${1}.png"
}

get_background_image() {
    osascript -e 'tell app "finder" to get posix path of (get desktop picture as alias)'
}

tldr() {
    # community driven documentation
    curl cheat.sh/"$1"
}

# Source: https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh
#
#   This file echoes a bunch of 24-bit color codes
#   to the terminal to demonstrate its functionality.
#   The foreground escape sequence is ^[38;2;<r>;<g>;<b>m
#   The background escape sequence is ^[48;2;<r>;<g>;<b>m
#   <r> <g> <b> range from 0 to 255 inclusive.
#   The escape sequence ^[0m returns output to default

24_bit_color_test() {

    setBackgroundColor() {
        echo -en "\x1b[48;2;$1;$2;$3""m"
    }

    resetOutput() {
        echo -en "\x1b[0m\n"
    }

    # Gives a color $1/255 % along HSV
    # Who knows what happens when $1 is outside 0-255
    # Echoes "$red $green $blue" where
    # $red $green and $blue are integers
    # ranging between 0 and 255 inclusive
    rainbowColor() {
        # shellcheck disable=SC2219
        let h=$1/43
        # shellcheck disable=SC2219
        let f=$1-43*$h
        # shellcheck disable=SC2219
        let t=$f*255/43
        # shellcheck disable=SC2219
        let q=255-t

        if [ "$h" -eq 0 ]; then
            echo "255 $t 0"
        elif [ "$h" -eq 1 ]; then
            echo "$q 255 0"
        elif [ "$h" -eq 2 ]; then
            echo "0 255 $t"
        elif [ "$h" -eq 3 ]; then
            echo "0 $q 255"
        elif [ "$h" -eq 4 ]; then
            echo "$t 0 255"
        elif [ "$h" -eq 5 ]; then
            echo "255 0 $q"
        else
            # execution should never reach here
            echo "0 0 0"
        fi
    }

    for i in $(seq 0 127); do
        setBackgroundColor "$i" 0 0
        echo -en " "
    done
    resetOutput
    for i in $(seq 255 128); do
        setBackgroundColor "$i" 0 0
        echo -en " "
    done
    resetOutput

    for i in $(seq 0 127); do
        setBackgroundColor 0 "$i" 0
        echo -n " "
    done
    resetOutput
    for i in $(seq 255 128); do
        setBackgroundColor 0 "$i" 0
        echo -n " "
    done
    resetOutput

    for i in $(seq 0 127); do
        setBackgroundColor 0 0 "$i"
        echo -n " "
    done
    resetOutput
    for i in $(seq 255 128); do
        setBackgroundColor 0 0 "$i"
        echo -n " "
    done
    resetOutput

    for i in $(seq 0 127); do
        setBackgroundColor "$(rainbowColor "$i")"
        echo -n " "
    done
    resetOutput
    for i in $(seq 255 128); do
        setBackgroundColor "$(rainbowColor "$i")"
        echo -n " "
    done
    resetOutput
}


reload() {
    # shellcheck source=/dev/null
    source "${HOME}/.bashrc"
}
