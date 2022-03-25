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
Plug 'chrisbra/Colorizer'                                                " https://github.com/chrisbra/Colorizer
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
Plug 'neoclide/coc.nvim', {'branch': 'release'}                          " https://github.com/neoclide/coc.nvim
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

let g:coc_global_extensions = [
      \ 'coc-git',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-metals',
      \ 'coc-prettier',
      \ 'coc-pyright',
      \ 'coc-snippets',
      \ 'coc-tsserver',
      \ 'coc-vetur',
      \ ]

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

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)


nmap ]g <Plug>(coc-git-nextchunk)
nmap [g <Plug>(coc-git-prevchunk)

nmap ]d <Plug>(coc-git-nextconflict)
nmap [d <Plug>(coc-git-prevconflict)

nmap gs <Plug>(coc-git-chunkinfo)
nmap gu <Plug>(coc-git-chunkundo)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OrderImports :call CocAction('runCommand', 'editor.action.organizeImport')

nmap <leader>rn <Plug>(coc-rename)

" Reference: https://scalameta.org/metals/docs/editors/vim.html
nnoremap <silent> <c-c>a :<C-u>CocList diagnostics<cr>
nnoremap <silent> <c-c>e :<C-u>CocList extensions<cr>
nnoremap <silent> <c-c>c :<C-u>CocList commands<cr>
nnoremap <silent> <c-c>o :<C-u>CocList outline<cr>
nnoremap <silent> <c-c>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <c-c>j :<C-u>CocNext<CR>
nnoremap <silent> <c-c>k :<C-u>CocPrev<CR>
nnoremap <silent> <c-c>p :<C-u>CocListResume<CR>
nnoremap <silent> <c-c>f :call CocAction('format')<CR>

" Toggle panel with Tree Views
nnoremap <silent> <c-c>t :<C-u>CocCommand metals.tvp<CR>

" Toggle Tree View 'metalsBuild'
nnoremap <silent> <c-c>tb :<C-u>CocCommand metals.tvp metalsBuild<CR>

" Toggle Tree View 'metalsCompile'
nnoremap <silent> <c-c>tc :<C-u>CocCommand metals.tvp metalsCompile<CR>

" Reveal current current class (trait or object) in Tree View 'metalsBuild'
nnoremap <silent> <c-c>tf :<C-u>CocCommand metals.revealInTreeView metalsBuild<CR>

nmap <Leader>ws <Plug>(coc-metals-expand-decoration)

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand)

" Use <C-j> for select text for visual placeholder of snippet.
vmap <C-j> <Plug>(coc-snippets-select)

" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<c-j>'

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'

" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use `wn` and `wp` instead of <tab> <s-tab>
nmap <Leader>wn <Plug>VimwikiNextLink
nmap <Leader>wp <Plug>VimwikiPrevLink

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
autocmd CursorHold * silent call CocActionAsync('highlight')

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
