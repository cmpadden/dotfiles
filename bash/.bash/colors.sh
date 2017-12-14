# --------------------------------------------------------------------------------
# DIR_COLORS
# --------------------------------------------------------------------------------

# eval "$(dircolors -b /etc/DIR_COLORS)"

# --------------------------------------------------------------------------------
# Colored man-pages
# --------------------------------------------------------------------------------

man() {
    LESS_TERMCAP_md=$'\e[01;31m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[01;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[01;32m' \
    command man "$@"
}

# --------------------------------------------------------------------------------
# GCC Warnings and Errors
# --------------------------------------------------------------------------------

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

