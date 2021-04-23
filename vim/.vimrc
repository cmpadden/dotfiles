scriptencoding utf-8

" set `no compatible` when compatible is set -- useful for  `vim -u <file>`
if &compatible
  " vint: next-line -ProhibitSetNoCompatible
  set nocompatible
endif

" Plugins {{{

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl
    \ --fail
    \ --location
    \ --output ~/.vim/autoload/plug.vim
    \ --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'SirVer/ultisnips'
Plug 'alok/notational-fzf-vim'
Plug 'chrisbra/Colorizer'
Plug 'chriskempson/base16-vim'
Plug 'dart-lang/dart-vim-plugin'
Plug 'honza/vim-snippets'
Plug 'jpalardy/vim-slime'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vimwiki/vimwiki'
Plug 'w0rp/ale'

Plug 'neoclide/coc.nvim', {'branch': 'release'}

let g:coc_global_extensions = [
      \ 'coc-json',
      \ 'coc-metals',
      \ 'coc-pyright',
      \ 'coc-ultisnips',
      \ 'coc-vetur',
      \ ]

" requires vim 8.1
if v:version >= 801
    Plug 'iamcco/markdown-preview.nvim', { 'do': {-> mkdp#util#install()} }
endif

" Initialize plugin system
call plug#end()

" }}}

" Mappings  {{{

let mapleader = "\<Space>"

nmap <leader>ve :e $MYVIMRC<CR>
nmap <leader>vv :source $MYVIMRC<CR>

" override `ag` command to exclude filenames in search
command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)

" fzf
nnoremap <c-f>b :Buffers<CR>
nnoremap <c-f>c :Colors<CR>
nnoremap <c-f>g :Ag<CR>
nnoremap <c-f>t :Tags<CR>
nnoremap <c-f>h :Helptags<CR>
nnoremap <c-f>l :Lines<CR>
nnoremap <c-f>n :GFiles<CR>
nnoremap <c-f>f :Files<CR>
nnoremap <c-f>s :Snippets<CR>
nnoremap <c-p> :GFiles<CR>

" ale
nmap <silent> ]e <Plug>(ale_next_wrap)
nmap <silent> [e <Plug>(ale_previous_wrap)

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

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
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

" UltiSnips
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsJumpBackwardTrigger = '<c-p>'
let g:UltiSnipsJumpForwardTrigger  = '<c-n>'
let g:UltiSnipsSnippetDirectories=['custom_snippets', 'UltiSnips']
let g:snips_author = 'Colton'

" Disable table navigation via tabs due to conflicts
let g:vimwiki_table_mappings = 0

" set VimWiki path, and use markdown as syntax
let g:vimwiki_list = [{'syntax': 'markdown',
                      \ 'ext': '.md'}]

" Save VimWiki to iCloud if possible
let s:icloud = expand('~/Library/Mobile Documents/com~apple~CloudDocs')
if isdirectory(s:icloud)
    let g:vimwiki_list[0].path = s:icloud . '/vimwiki'
    let g:nv_search_paths = [s:icloud . '/vimwiki']
else
    let g:nv_search_paths = ['~/vimwiki']
endif

" notational-fzf-vim
let g:nv_create_note_key = 'ctrl-x'

" don't associate external markdown files outside of vimwiki as vmiwiki " filetype
" https://github.com/vimwiki/vimwiki/issues/95
let g:vimwiki_global_ext = 0

" Ale
let g:ale_sign_column_always = 0
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'
let g:ale_fix_on_save = 0
let g:ale_fixers = {
\   '*':      ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8', 'yapf'],
\   'yaml':   ['prettier'],
\   'markdown': ['prettier'],
\}
let g:ale_linters = {
\   'python': ['flake8', 'mypy'],
\   'markdown': ['proselint', 'mdl'],
\}

" Airline
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
let g:airline_theme='minimalist'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#bufferline#enabled = 1

" Slime
let g:slime_target = 'tmux'
let g:slime_default_config = {'socket_name': 'default', 'target_pane': '{last}'}
let g:slime_dont_ask_default = 1

" EditorConfig
let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']

" disable persistant directory listings
let g:netrw_fastbrowse = 0

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

" Commands {{{

command! Hex :%!xxd
command! Dehex :%!xxd -r

" Define user commands for updating/cleaning the plugins.  Each of them loads
" minpac, reloads .vimrc to register the information of plugins, then performs
" the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()

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

" https://github.com/chriskempson/base16-vim/#256-colorspace
let base16colorspace=256

" apply base16 colorscheme
set background=light
" colorscheme base16-solarized-light

" no background on gutter
highlight clear SignColumn

" use foreground colors for gutter icons
highlight ALEErrorSign ctermfg=DarkRed ctermbg=NONE
highlight ALEWarningSign ctermfg=Yellow ctermbg=NONE

" https://codeyarns.com/2011/07/29/vim-set-color-of-colorcolumn/
highlight ColorColumn ctermbg=18

" }}}
