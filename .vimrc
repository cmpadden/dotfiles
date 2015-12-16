set encoding=utf-8

call pathogen#infect()
call pathogen#helptags()

if !exists("g:syntax_on")
    syntax enable
endif

set background=dark
colorscheme solarized

set colorcolumn=80
highlight ColorColumn ctermbg=4

filetype plugin indent on

set relativenumber

set tabstop=4
set shiftwidth=4
set expandtab
let mapleader = ","

" enable spellcheck when editing .tex documents
autocmd FileType tex setlocal spell spelllang=en_us
