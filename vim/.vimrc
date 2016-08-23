" file: .vimrc

set encoding=utf-8
set term=screen-256color

call pathogen#infect()
call pathogen#helptags()

set number
set relativenumber

set nowrap

set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4

filetype indent on

syntax enable
set background=light
colorscheme solarized

set colorcolumn=80
highlight ColorColumn ctermbg=4

set foldmethod=marker

let mapleader = "\<Space>"
let g:slime_target = "tmux"
let g:slime_python_ipython = 1

