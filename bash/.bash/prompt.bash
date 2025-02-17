#!/usr/bin/env bash

#
# Gets current working Python virtual environemnt including direnv.
#
# Reference(s):
#   https://github.com/direnv/direnv/wiki/Python#restoring-the-ps1
#
prompt_venv()
{
    if [[ -n "$VIRTUAL_ENV" && -n "$DIRENV_DIR" ]]; then
        if [[ -n "$UV_ACTIVE" ]]; then
            printf "uv "
        else
            printf "%s " "$(basename "$VIRTUAL_ENV")"
        fi
    fi
}

#
# Gets current working Git branch.
#
# Reference(s):
#   https://www.shellhacks.com/show-git-branch-terminal-command-prompt/
#
prompt_git_branch()
{
    if git rev-parse --git-dir >/dev/null 2>&1; then
        printf "%s " "$(git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
    fi
}

# | Code    | Effect                       | Note                                                                   |
# |---------|------------------------------|------------------------------------------------------------------------|
# | 0       | Reset / Normal               | all attributes off                                                     |
# | 1       | Bold or increased intensity  |                                                                        |
# | 2       | Faint (decreased intensity)  | Not widely supported.                                                  |
# | 3       | Italic                       | Not widely supported. Sometimes treated as inverse.                    |
# | 4       | Underline                    |                                                                        |
# | 5       | Slow Blink                   | less than 150 per minute                                               |
# | 6       | Rapid Blink                  | MS-DOS ANSI SYS; 150+ per minute; not widely supported                 |
# | 7       | [[reverse video]]            | swap foreground and background colors                                  |
# | 8       | Conceal                      | Not widely supported.                                                  |
# | 9       | Crossed-out                  | Characters legible, but marked for deletion. Not widely supported.     |
# | 10      | Primary(default) font        |                                                                        |
# | 11-19   | Alternate font               | Select alternate font n-10                                             |
# | 20      | Fraktur                      | hardly ever supported                                                  |
# | 21      | Bold off or Double Underline | Bold off not widely supported; double underline hardly ever supported. |
# | 22      | Normal color or intensity    | Neither bold nor faint                                                 |
# | 23      | Not italic, not Fraktur      |                                                                        |
# | 24      | Underline off                | Not singly or doubly underlined                                        |
# | 25      | Blink off                    |                                                                        |
# | 27      | Inverse off                  |                                                                        |
# | 28      | Reveal                       | conceal off                                                            |
# | 29      | Not crossed out              |                                                                        |
# | 30-37   | Set foreground color         | See color table below                                                  |
# | 38      | Set foreground color         | Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below                   |
# | 39      | Default foreground color     | implementation defined (according to standard)                         |
# | 40-47   | Set background color         | See color table below                                                  |
# | 48      | Set background color         | Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below                   |
# | 49      | Default background color     | implementation defined (according to standard)                         |
# | 51      | Framed                       |                                                                        |
# | 52      | Encircled                    |                                                                        |
# | 53      | Overlined                    |                                                                        |
# | 54      | Not framed or encircled      |                                                                        |
# | 55      | Not overlined                |                                                                        |
# | 60      | ideogram underline           | hardly ever supported                                                  |
# | 61      | ideogram double underline    | hardly ever supported                                                  |
# | 62      | ideogram overline            | hardly ever supported                                                  |
# | 63      | ideogram double overline     | hardly ever supported                                                  |
# | 64      | ideogram stress marking      | hardly ever supported                                                  |
# | 65      | ideogram attributes off      | reset the effects of all of 60-64                                      |
# | 90-97   | Set bright foreground color  | aixterm (not in standard)                                              |
# | 100-107 | Set bright background color  | aixterm (not in standard)                                              |

# Applies custom prompt when `xterm-256color` is active (eg. when in tmux)
#
# Reference(s):
#  - https://wiki.gentoo.org/wiki/Bash#PS1 for more information
#  - https://wiki.archlinux.org/title/Bash/Prompt_customization
#  - https://stackoverflow.com/a/33206814
#  - https://www.shellcheck.net/wiki/SC2025
#
if [ "$TERM" == "xterm-256color" ]; then
    PS1='\[\e[33m\]$(prompt_venv)\[\e[0m\]'
    PS1+='\[\e[34m\]$(prompt_git_branch)\[\e[0m\]'
    PS1+='\[\e[33m\]\w\[\e[0m\]'
    PS1+='\n\$ '
fi
