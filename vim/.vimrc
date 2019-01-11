if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
    Plug 'junegunn/fzf.vim'

    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'

    Plug 'junegunn/vim-easy-align'
    Plug 'mrtazz/simplenote.vim'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-surround'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'vimwiki/vimwiki'
    Plug 'w0rp/ale'

call plug#end()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Mappings                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader = "\<Space>"

" fzf
nnoremap <c-f>b :Buffers<CR>
nnoremap <c-f>c :Commits<CR>
nnoremap <c-f>g :Ag<CR>
nnoremap <c-f>f :GFiles<CR>
nnoremap <c-f>h :Helptags<CR>
nnoremap <c-f>l :Lines<CR>
nnoremap <c-f>n :Files<CR>
nnoremap <c-f>s :Snippets<CR>

" ale
nmap <silent> [e <Plug>(ale_next_wrap)
nmap <silent> ]e <Plug>(ale_previous_wrap)
nnoremap <c-a>f :ALEFix<CR>

" easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" buffer navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>

" command navigation
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                          Configuration Variables                           "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Snippets
let g:UltiSnipsJumpForwardTrigger  = '<c-n>'
let g:UltiSnipsJumpBackwardTrigger = '<c-p>'
let g:UltiSnipsEditSplit = 'vertical'

" Wiki (table tabs prevent ultisnips)
let g:vimwiki_table_mappings = 0
let g:vimwiki_folding = 'expr'

" Ale
let g:ale_sign_column_always = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['flake8'],
\   'ruby': ['rubocop'],
\   'yaml': ['prettier'],
\}

" airline
let g:airline_theme='minimalist'

" simplenote
let g:SimplenoteFiletype = 'markdown'
let g:SimplenoteSingleWindow = 1
let g:SimplenoteVertical = 1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Settings                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set hidden
set ignorecase
set incsearch
set list listchars=tab:>-,trail:.,extends:>
set noswapfile
set nowrap
set smartcase

set expandtab
set shiftwidth=4
set smarttab
set softtabstop=0

set textwidth=80

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Commands                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Hex :%!xxd
command! Dehex :%!xxd -r
