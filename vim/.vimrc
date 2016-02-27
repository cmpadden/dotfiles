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

set tabstop=2
set shiftwidth=2
set expandtab
let mapleader = ","

" enable spellcheck when editing .tex documents
autocmd FileType tex setlocal spell spelllang=en_us

" enable tmux support for slime-vim
let g:slime_target = "tmux"

" elixir specific settings
" au BufRead,BufNewFile *.ex, *.exs   set tabstop=2
" au BufRead,BufNewFile *.ex, *.exs   set shiftwidth=2
