syntax on

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'


" bundle for jedi-vim python completion
Bundle 'davidhalter/jedi-vim'

" bundle for supertab tab for insert completion
Bundle 'ervandew/supertab'

" bundle for nerdtree filesystem exploration plugin
" Bundle 'scrooloose/nerdtree'

    " settings for nerdtree
    " open a NERDTree automatically when vim starts up
    " autocmd vimenter * NERDTree

    " open a NERDTree automatically when vim starts up if no files were specified
    " autocmd vimenter * if !argc() | NERDTree | endif

    " close vim if the only window left open is a NERDTree
    " autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif


" bundle for vim-airline a lean and mean status/tabline
" Bundle 'bling/vim-airline'

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList          - list configured plugins
" :PluginInstall(!)    - install (update) plugins
" :PluginSearch(!) foo - search (or refresh cache first) for foo
" :PluginClean(!)      - confirm (or auto-approve) removal of unused plugins
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" code formatting
set autoindent		" automatically indent on new lines
set expandtab		" expand tabs to spaces
set tabstop=8		" actual tab width
set softtabstop=4	" insert mode tab/backspace width
set shiftwidth=4	" normal mode (auto)indent width
set backspace=2		" improve the working of <BS>, <Del>, CTRL-W and CTRL-U in insert mode.

" editor setup
set autoread                                                            " reload files when they are updated
set clipboard=unnamed                                                   " use system clipboard for yanking and putting
set encoding=utf-8                                                      " define char set
set laststatus=2 " always show status line
set list                                                                " show whitespqace
set listchars=tab:→\ ,trail:·
set wrap                                                                " wrapping by default
set showcmd                                                             " give info on current command
set number                                                              " show line numbers
set hidden                                                              " hide buffers instead of unloading them
set report=0                                                            " Always report number of lines changed
set ruler                                                               " show line and column number of cursor
set cursorline                                                          " higlight screen line of the cursor
set scrolloff=4                                                         " scroll offset
set showmatch                                                           " When a bracket is inserted, briefly jump to the matching one
set background=dark                                                     " try to use colors that look good on a dark background
set colorcolumn=80                                                      " add a marker to lines longer than 80 columns
hi ColorColumn ctermbg=lightgrey guibg=lightgrey 


" search
set ignorecase " case-insensitive search
set smartcase " case-sensitive search if query contains caps
set hlsearch " highlight search results
set incsearch " search as you type

" automatically reload vimrc when it's saved
au BufWritePost .vimrc so ~/.vimrc
