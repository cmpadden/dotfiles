" Plugins {{{

" https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.local/share/nvim/site/autoload/plug.vim'))
  silent !curl
    \ --fail
    \ --location
    \ --output ~/.local/share/nvim/site/autoload/plug.vim
    \ --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(stdpath('data') . '/plugged')

" NOTE: use `gx` to open a URL in the web browser

Plug 'editorconfig/editorconfig-vim'                                     " https://github.com/editorconfig/editorconfig-vim
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }                       " https://github.com/folke/tokyonight.nvim
Plug 'ggandor/lightspeed.nvim'                                           " https://github.com/ggandor/lightspeed.nvim
Plug 'heavenshell/vim-jsdoc', { 'do': 'make install' }                   " https://github.com/heavenshell/vim-jsdoc
Plug 'honza/vim-snippets'                                                " https://github.com/honza/vim-snippets
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  } " https://github.com/iamcco/markdown-preview.nvim
Plug 'joosepalviste/nvim-ts-context-commentstring'                       " https://github.com/JoosepAlviste/nvim-ts-context-commentstring
Plug 'jpalardy/vim-slime'                                                " https://github.com/jpalardy/vim-slime
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }        " https://github.com/junegunn/fzf
Plug 'junegunn/fzf.vim'                                                  " https://github.com/junegunn/fzf.vim
Plug 'junegunn/vim-easy-align'                                           " https://github.com/junegunn/vim-easy-align
Plug 'lervag/vimtex'                                                     " https://github.com/lervag/vimtex
Plug 'lewis6991/gitsigns.nvim'                                           " https://github.com/lewis6991/gitsigns.nvim
Plug 'norcalli/nvim-colorizer.lua'                                       " https://github.com/norcalli/nvim-colorizer.lua
Plug 'nvim-lua/plenary.nvim'                                             " https://github.com/nvim-lua/plenary.nvim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}              " https://github.com/nvim-treesitter/nvim-treesitter
Plug 'nvim-treesitter/playground'                                        " https://github.com/nvim-treesitter/playground
Plug 'tpope/vim-commentary'                                              " https://github.com/tpope/vim-commentary
Plug 'tpope/vim-dadbod'                                                  " https://github.com/tpope/vim-dadbod
Plug 'tpope/vim-fugitive'                                                " https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-obsession'                                               " https://github.com/tpope/vim-obsession
Plug 'tpope/vim-rhubarb'                                                 " https://github.com/tpope/vim-rhubarb
Plug 'tpope/vim-surround'                                                " https://github.com/tpope/vim-surround
Plug 'vim-airline/vim-airline'                                           " https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline-themes'                                    " https://github.com/vim-airline/vim-airline-themes

" LSP and Completion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'SirVer/ultisnips'
Plug 'quangnguyen30192/cmp-nvim-ultisnips'

" Plug 'w0rp/ale'
" Plug 'nvim-lua/plenary.nvim'
" Plug 'nvim-telescope/telescope.nvim'
" Plug 'sheerun/vim-polyglot'
" Plug 'SirVer/ultisnips'

" Initialize plugin system
call plug#end()

" }}}

" Mappings  {{{

let mapleader = "\<Space>"

nmap <leader>ve :e $MYVIMRC<CR>
nmap <leader>vr :source $MYVIMRC<CR>

" override `ag` command to exclude filenames in search
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" fzf
nnoremap <c-f>b :Buffers<CR>
nnoremap <c-f>c :BCommits<CR>
nnoremap <c-f>g :Ag<CR>
nnoremap <c-f>h :Helptags<CR>
nnoremap <c-f>l :Lines<CR>
nnoremap <c-f>n :GFiles<CR>
nnoremap <c-f>f :Files<CR>
nnoremap <c-f>s :Snippets<CR>

" easy-align
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

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

" run SQL on last using this currently hard-coded DB
vnoremap <C-r> :DB g:d<CR>

" run Python code
augroup pythonMappings
    autocmd!
    autocmd Filetype python nnoremap <buffer> <F5> :exec '!python' shellescape(@%, 1)<cr>
augroup END

" Notes
nnoremap <silent> <leader>nn :NV<CR>

" set workspace for python files
" https://github.com/neoclide/coc.nvim/wiki/Using-workspaceFolders#resolve-workspace-folder
autocmd FileType python let b:coc_root_patterns = ['.envrc', '.git']

" }}}

" Global Variables (Plugin Configurations) {{{

lua << EOF
require'nvim-treesitter.configs'.setup {
  context_commentstring = {
    enable = true
  }
}
EOF

" Goyo
let g:goyo_height = '100%'

" Airline
let g:airline#extensions#coc#enabled = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_theme='minimalist'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#bufferline#enabled = 1

" Slime
let g:slime_target = 'tmux'
let g:slime_default_config = {"socket_name": "default", "target_pane": "{last}"}
let g:slime_dont_ask_default = 1

" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']

" disable persistant directory listings
let g:netrw_fastbrowse = 0

" markdown-preview
" let g:mkdp_auto_start = 0 " open the preview window after entering the markdown buffer

" }}}

" General Settings {{{

" https://neovim.io/doc/user/vim_diff.html
" set hidden
" set incsearch
" set backspace=2

set list listchars=tab:>-,trail:.,extends:>
set noswapfile
set nowrap
set ignorecase
set smartcase

set expandtab
set shiftwidth=4
set smarttab
set softtabstop=0

set textwidth=120
set colorcolumn=80


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

" Commands {{{

command! Hex :%!xxd
command! Dehex :%!xxd -r

" alias :W to :w for sanity reasons
command! W w

" }}}

" Auto Commands {{{

" after opening `help` files, move them to the right
augroup helpFileType
    autocmd!
    autocmd FileType help wincmd L
augroup END

" enable spell checking for certain file types
augroup spellChecking
    autocmd!
    autocmd FileType vimwiki setlocal spell
    autocmd FileType markdown setlocal spell
augroup END

" Help Vim recognize *.sbt and *.sc as Scala files
augroup scalaFiletypes
    autocmd BufRead,BufNewFile *.sbt,*.sc set filetype=scala
augroup END

" Highlight the symbol and its references when holding the cursor.
" autocmd CursorHold * silent call CocActionAsync('highlight')

augroup foldmethod_markers
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
    autocmd FileType python setlocal foldmethod=marker
augroup END

" }}}

" Functions {{{

function! ToggleSignColumn()
    if &signcolumn ==# 'no'
        let &signcolumn = 'yes'
    else
        let &signcolumn = 'no'
    endif
endfunction

" }}}

" Formatting and Colors {{{

set signcolumn=yes

" support true colors
set termguicolors

let g:tokyonight_style = "night"
colorscheme tokyonight

" no background on gutter
" highlight clear SignColumn

" https://codeyarns.com/2011/07/29/vim-set-color-of-colorcolumn/
" highlight ColorColumn ctermbg=223

" }}}

" Lua Configuration {{{

" References
" * https://github.com/nanotee/nvim-lua-guide
" * https://github.com/hrsh7th/nvim-cmp/
" * https://github.com/neovim/nvim-lspconfig
" * https://github.com/neovim/nvim-lspconfig#suggested-configuration
" * https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
" * https://github.com/neovim/nvim-lspconfig/wiki/Autocompletion#nvim-cmp
" * https://github.com/scalameta/nvim-metals/discussions/39
"
" Dependencies
" * brew install pyright
" * brew install rust-analyzer
" * brew install lua-language-server
" * npm i -g typescript typescript-language-server
" * npm i -g vls
" * npm i -g vscode-langservers-extracted
" * npm i -g @tailwindcss/language-server
" * npm i -g bash-language-server

lua require('user.plugins')
lua require('user.lsp')
