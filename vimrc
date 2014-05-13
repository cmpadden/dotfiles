syntax on

set nocompatible              " be iMproved, required
filetype off                  " required

" vundle
filetype on                   " avoid zero exit status
filetype off
" set rtp+=~/.vim/bundle/vundle/  " set the runtime path to include Vundle and initialize
" call vundle#rc()

" let Vundle manage Vundle, required
" Bundle 'gmarik/vundle'

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

" look into YouCompleteMe
" Bundle 'Valloric/YouCompleteMe'

filetype plugin indent on     " required

" code formatting
set autoindent		" automatically indent on new lines
set noexpandtab		" doesn't expand tabs to spaces
set tabstop=8		" actual tab width
set softtabstop=8	" insert mode tab/backspace width
set shiftwidth=8	" normal mode (auto)indent width
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

" search
set ignorecase " case-insensitive search
set smartcase " case-sensitive search if query contains caps
set hlsearch " highlight search results
set incsearch " search as you type

" automatically reload vimrc when it's saved
au BufWritePost .vimrc so ~/.vimrc
