" Plugins
call plug#begin()

    Plug 'tpope/vim-sensible'
    Plug 'ctrlpvim/ctrlp.vim'
    Plug 'vimwiki/vimwiki'

    Plug 'rust-lang/rust.vim', { 'for': 'rust' }

call plug#end()

" Leader
let mapleader = "\<Space>"
map <Leader>vr :r source ~/.vimrc<CR>
map <Leader>ve :e ~/.vimrc<CR>

if !empty(glob("~/.vim/plugged/ctrlp.vim"))
    map <Leader>ff :CtrlP<CR>
    map <Leader>fc :CtrlP .<CR> 
    map <Leader>fb :CtrlPBuffer<CR> 
    map <Leader>fm :CtrlPMixed<CR>
endif

" Misc.
set nowrap
set background=dark
set foldmethod=marker
