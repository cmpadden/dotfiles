#!/usr/bin/env bash

extract() {
    # compressed file expander
    # https://github.com/myfreeweb/zshuery/blob/master/zshuery.sh
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

define() {
    # define words
    # http://vikros.tumblr.com/post/23750050330/cute-little-function-time
    if [ $# -ge 2 ]; then
        echo "givedef: too many arguments" >&2
        return 1
    else
        curl "dict://dict.org/d:$1"
    fi
}

decaesar() {
    # attempt all variants of caesar cipher
    # https://chris-lamb.co.uk/posts/decrypting-caesar-cipher-using-shell
    for I in $(seq 25); do
        echo "$1" | tr "[:lower:]" "[:upper:]" | tr $(printf "%${I}s" | tr ' ' '.')\A-Z A-ZA-Z
    done
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

fd() {
  # FZF change directories
  local dir
  dir=$(find ${1:-.} -type d 2> /dev/null | fzf +m) && cd "$dir" || exit
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
      echo $pid | xargs kill -${1:-9}
  fi
}

fgb() {
  # FZF checkout git branches, w/ remote branches
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" | fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
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
  echo $prog
  if [ -n "$prog" ]; then
    brew install "$prog"
  fi
}

color_codes() {
    for i in {0..255} ; do
        printf "%3d \x1b[48;5;%sm   \e[0m " "$i" "$i"
        if (( (i+1) % 8 == 0 )); then
            printf "\n";
        fi
    done
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
  convert -size 100x100 xc:"$1" "100x00_${1}.png"
}


mkpyenv() {
    echo "layout python-venv python3" >> .envrc
}

get_background_image() {
    osascript -e 'tell app "finder" to get posix path of (get desktop picture as alias)'
}

cheat() {
    # community driven documentation
    curl cheat.sh/"$1"
}

