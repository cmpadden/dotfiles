#!/usr/bin/env bash

# -------------------------------------------------------------------
# compressed file expander
# (from https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh)
# -------------------------------------------------------------------

extract() {
    if [[ -f $1 ]]; then
        case $1 in
          *.tar.bz2) tar xvjf "$1";;
          *.tar.gz) tar xvzf "$1";;
          *.tar.xz) tar xvJf "$1";;
          *.tar.lzma) tar --lzma xvf "$1";;
          *.bz2) bzip2 -d "$1";;
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


# -------------------------------------------------------------------
# Java Decompile using IntelliJ
# -------------------------------------------------------------------

java_decompile() {

    # Ensure 2 arguments are passed
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

    java -cp /Applications/IntelliJ\ IDEA\ CE.app/Contents/plugins/java-decompiler/lib/java-decompiler.jar \
        org.jetbrains.java.decompiler.main.decompiler.ConsoleDecompiler "$1" "$2"
}


# -------------------------------------------------------------------
# Trigger notification (useful for things like sleep 5 && notify)
# -------------------------------------------------------------------

notify() {
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

# -------------------------------------------------------------------
# Temporary File Server
# -------------------------------------------------------------------

serve() {

openssl req \
  -new \
  -newkey rsa:4096 \
  -days 365 \
  -nodes \
  -x509 \
  -subj "/C=US/ST=DC/L=Washington/O=Tmp/CN=localhost" \
  -keyout localhost.key \
  -out localhost.cert

python3 << EOF
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

# -------------------------------------------------------------------
# fzf [https://github.com/junegunn/fzf/wiki/examples]
# -------------------------------------------------------------------

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir" || exit
}

# fkill - kill processes
fkill() {
  local pid
  if [ "$UID" != "0" ]; then
      pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
      pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi

  if [ "x$pid" != "x" ]; then
      echo $pid | xargs kill -${1:-9}
  fi
}

# fbr - checkout git branch (including remote branches)
fgb() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

fpass() {
  local stores store
  stores=$(find "$HOME/.password-store/" -name "*.gpg" | sed 's/^.*-store\/\/\(.*\)\.gpg/\1/g')
  store=$(echo "$stores" | fzf +m)
  pass -c "$store"
}

fbrew() {
  local prog
  prog=$(brew search | fzf +m)
  echo $prog
  if [ -n "$prog" ]; then
    brew install "$prog"
  fi
}

# -------------------------------------------------------------------
# color codes
# -------------------------------------------------------------------

color_codes() {
    for i in {0..255} ; do
        printf "%3d \x1b[48;5;%sm   \e[0m " "$i" "$i"
        if (( (i+1) % 8 == 0 )); then
            printf "\n";
        fi
    done
}

# -------------------------------------------------------------------
# fzf for search pydocs
# -------------------------------------------------------------------

fpy() {
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
