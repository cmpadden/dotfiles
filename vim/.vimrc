set encoding=utf-8

call pathogen#infect()
call pathogen#helptags()

set relativenumber
set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
filetype indent on

if !exists("g:syntax_on")
    syntax enable
endif

set background=dark

set colorcolumn=80
highlight ColorColumn ctermbg=4

" Leader Key
let mapleader = "\<Space>"

" enable tmux support for slime-vim
let g:slime_target = "tmux"
let g:slime_python_ipython = 1
