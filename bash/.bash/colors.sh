#!/usr/bin/env bash

# --------------------------------------------------------------------------------
# DIR_COLORS
# --------------------------------------------------------------------------------

# eval "$(dircolors -b /etc/DIR_COLORS)"

# --------------------------------------------------------------------------------
# Colored man-pages
# --------------------------------------------------------------------------------

# https://wiki.archlinux.org/title/Color_output_in_console#man
export MANPAGER="less -R --use-color -Dd+r -Du+b"

# --------------------------------------------------------------------------------
# GCC Warnings and Errors
# --------------------------------------------------------------------------------

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
