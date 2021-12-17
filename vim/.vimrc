scriptencoding utf-8

" set `no compatible` when compatible is set -- useful for  `vim -u <file>`
if &compatible
  " vint: next-line -ProhibitSetNoCompatible
  set nocompatible
endif

" Mappings  {{{

" buffer navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" command navigation
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" visually selected search
vnoremap // y/\V<C-R>"<CR>

" repeated indentation
vnoremap < <gv
vnoremap > >gv

" }}}

" General Settings {{{

filetype indent plugin on

syntax on

set hidden
set incsearch
set list listchars=tab:>-,trail:.,extends:>
set noswapfile
set nowrap
set ignorecase
set smartcase

set expandtab
set shiftwidth=4
set smarttab
set softtabstop=0

set textwidth=79
set colorcolumn=80

set backspace=2

" increase height to improve message visiliity
set cmdheight=2

" hide scrollbars in GUI
if has('gui')
    set guioptions-=r
    set guioptions-=L
endif

set dictionary=/usr/share/dict/words

" language servers can have issues with backup files
set nobackup
set nowritebackup

" number of milliseconds for swap file to be written
" decreasing this improves diagnostic messages in coc-nvim
set updatetime=300

" }}}
