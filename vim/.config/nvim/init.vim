if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


call plug#begin()

    " General
    " ----------------------------------------
    Plug 'vimwiki/vimwiki'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'edkolev/tmuxline.vim'
    Plug 'tpope/vim-tbone'
    Plug 'vim-scripts/SyntaxRange'


    " Searching
    " ----------------------------------------
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'


    " Filetype Plugins
    " ----------------------------------------
    Plug 'fatih/vim-go',            { 'for': 'go' }
    Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
    Plug 'rust-lang/rust.vim',      { 'for': 'rust' }
    Plug 'udalov/kotlin-vim',       { 'for': 'kotlin' }
    Plug 'pearofducks/ansible-vim'


    " Completion, Snippets, and Linting
    " ----------------------------------------
    Plug 'SirVer/ultisnips'
    Plug 'honza/vim-snippets'
    Plug 'roxma/nvim-completion-manager'
    Plug 'w0rp/ale'


    " Editing
    " ----------------------------------------
    Plug 'junegunn/goyo.vim'
    Plug 'junegunn/vim-easy-align'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'


    " Version Control
    " ----------------------------------------
    Plug 'tpope/vim-fugitive'

call plug#end()

let mapleader = "\<Space>"
map <Leader>vr :source $MYVIMRC<CR>
map <Leader>ve :e $MYVIMRC<CR>

" ------------------------------------------------------------------------------
" Snippets
" ------------------------------------------------------------------------------

let g:UltiSnipsJumpForwardTrigger  = "<c-n>"
let g:UltiSnipsJumpBackwardTrigger = "<c-p>"

" ------------------------------------------------------------------------------
" FZF
" ------------------------------------------------------------------------------

nnoremap <c-f>s :Snippets<CR>
nnoremap <c-f>n :Files<CR>
nnoremap <c-f>f :Ag<CR>
nnoremap <c-f>c :Colors<CR>
nnoremap <c-f>l :Lines<CR>
nnoremap <c-f>b :Buffers<CR>
nnoremap <c-f>h :Helptags<CR>
nnoremap <c-f>g :Commits<CR>

" ------------------------------------------------------------------------------
" vim-tbone
" ------------------------------------------------------------------------------

xnoremap <leader>th :Twrite left<CR>
xnoremap <leader>tj :Twrite bottom<CR>
xnoremap <leader>tk :Twrite top<CR>
xnoremap <leader>tl :Twrite right<CR>

" ------------------------------------------------------------------------------
" Easy Align
" ------------------------------------------------------------------------------

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" ------------------------------------------------------------------------------
" ALE - Asynchronous Lint Engine
" ------------------------------------------------------------------------------

let g:airline#extensions#ale#enabled   = 1
let g:ale_set_highlights               = 0
let g:ale_sign_column_always           = 1
let g:ale_warn_about_trailing_whitespace = 0

let g:ale_sign_error   = 'E>'
let g:ale_sign_warning = 'W>'
let g:ale_sign_info    = 'I>'

" matching gutter color
highlight clear SignColumn

" let g:ale_linters = {
" \   'ansible': ['ansible-lint'],
" \   'java': ['checkstyle'],
" \   'python': ['pylint'],
" \   'xml': ['xmllint'],
" \}

" Navigate between erroes
nmap <silent> ]e <Plug>(ale_previous_wrap)
nmap <silent> [e <Plug>(ale_next_wrap)

" ------------------------------------------------------------------------------
" Airline - Lean & mean status/tabline for vim that's light as air.
" ------------------------------------------------------------------------------

let g:airline_theme='luna'
let g:airline#extensions#tabline#enabled = 1
let g:tmuxline_powerline_separators = 0

" ------------------------------------------------------------------------------
" Goyo - Distraction-free writing in Vim.
" ------------------------------------------------------------------------------

nmap <Leader>df :Goyo<CR>

" ------------------------------------------------------------------------------
" Functions
" ------------------------------------------------------------------------------

" Remove Trailing Whitespace
function! RemoveTrailingSpace()
    %s/\s\+$//e
endfunction
nmap <Leader>rtw :call RemoveTrailingSpace()<CR>


" ------------------------------------------------------------------------------
" SyntaxRange
" ------------------------------------------------------------------------------

" Java syntax between <Source></Source> or <Source><![[CDATA[]]></Source>
autocmd FileType xml call SyntaxRange#Include('<[Ss]ource>\(\s*<!\[CDATA\[\)\?', '\(\s*\]\]>\)\?</[Ss]ource>', 'java', 'NonText')" 

" ------------------------------------------------------------------------------
" vim-markdown - Syntax highlighting, matching rules and mappings...
" ------------------------------------------------------------------------------

let g:vim_markdown_folding_disabled = 1

" ------------------------------------------------------------------------------
" Settings
" ------------------------------------------------------------------------------

set nowrap
set hidden
set noswapfile
set list listchars=tab:>-,trail:.,extends:>

" Move between buffers
nnoremap <C-p> :bprev<CR>
nnoremap <C-n> :bnext<CR>

" Command Mappings
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>

" Searching
set ignorecase
set smartcase
