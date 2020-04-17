scriptencoding utf-8

" set `no compatible` when compatible is set -- useful for  `vim -u <file>`
if &compatible
  " vint: next-line -ProhibitSetNoCompatible
  set nocompatible
endif

" Plugins {{{

if empty(glob('~/.vim/pack/minpac/opt/minpac'))
    silent !git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
endif

if exists('*minpac#init')

    " minpac
    call minpac#init()
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " Additional plugins
    call minpac#add('SirVer/ultisnips')
    call minpac#add('editorconfig/editorconfig-vim')
    call minpac#add('honza/vim-snippets')
    call minpac#add('jpalardy/vim-slime')
    call minpac#add('junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' })
    call minpac#add('junegunn/fzf.vim')
    call minpac#add('junegunn/goyo.vim')
    call minpac#add('junegunn/vim-easy-align')
    call minpac#add('plytophogy/vim-virtualenv')
    call minpac#add('sheerun/vim-polyglot')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-dadbod')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('tpope/vim-obsession')
    call minpac#add('tpope/vim-surround')
    call minpac#add('vim-airline/vim-airline')
    call minpac#add('vim-airline/vim-airline-themes')
    call minpac#add('vimwiki/vimwiki')
    call minpac#add('w0rp/ale')

    call minpac#add('chrisbra/Colorizer')

    call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
    " let g:coc_global_extensions = [
    "       \ 'coc-json',
    "       \ 'coc-metals',
    "       \ 'coc-python',
    "       \ 'coc-ultisnips',
    "       \ 'coc-vetur',
    "       \ ]

    " requires vim 8.1
    if v:version >= 801
        call minpac#add('iamcco/markdown-preview.nvim', { 'do': {-> mkdp#util#install()} })
    endif

endif

" }}}

" Mappings  {{{

let mapleader = "\<Space>"

nmap <leader>ve :e $MYVIMRC<CR>
nmap <leader>vv :source $MYVIMRC<CR>


" override `ag` command to exclude filenames in search
"
" -n, --nth=N[,..]      Comma-separated list of field index expressions
"                       for limiting search scope. Each can be a non-zero
"                       integer or a range expression ([BEGIN]..[END]).
" -d, --delimiter=STR   Field delimiter regex (default: AWK-style)
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

" ale
nmap <silent> ]e <Plug>(ale_next_wrap)
nmap <silent> [e <Plug>(ale_previous_wrap)
nnoremap <leader>af :ALEFix<CR>

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

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OrderImports :call CocAction('runCommand', 'editor.action.organizeImport')

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

nmap <leader>rn <Plug>(coc-rename)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Reference: https://scalameta.org/metals/docs/editors/vim.html

nnoremap <silent> <c-c>a :<C-u>CocList diagnostics<cr>
nnoremap <silent> <c-c>e :<C-u>CocList extensions<cr>
nnoremap <silent> <c-c>c :<C-u>CocList commands<cr>
nnoremap <silent> <c-c>o :<C-u>CocList outline<cr>
nnoremap <silent> <c-c>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <c-c>j :<C-u>CocNext<CR>
nnoremap <silent> <c-c>k :<C-u>CocPrev<CR>
nnoremap <silent> <c-c>p :<C-u>CocListResume<CR>

" Toggle panel with Tree Views
nnoremap <silent> <c-c>t :<C-u>CocCommand metals.tvp<CR>

" Toggle Tree View 'metalsBuild'
nnoremap <silent> <c-c>tb :<C-u>CocCommand metals.tvp metalsBuild<CR>

" Toggle Tree View 'metalsCompile'
nnoremap <silent> <c-c>tc :<C-u>CocCommand metals.tvp metalsCompile<CR>

" Reveal current current class (trait or object) in Tree View 'metalsBuild'
nnoremap <silent> <c-c>tf :<C-u>CocCommand metals.revealInTreeView metalsBuild<CR>

" Use `wn` and `wp` instead of <tab> <s-tab>
nmap <Leader>wn <Plug>VimwikiNextLink
nmap <Leader>wp <Plug>VimwikiPrevLink

map <silent> <leader>wf :Files ~/vimwiki<cr>

" }}}

" Global Variables (Plugin Configurations) {{{

" UltiSnips

let g:UltiSnipsJumpForwardTrigger  = '<c-n>'
let g:UltiSnipsJumpBackwardTrigger = '<c-p>'
let g:UltiSnipsEditSplit = 'vertical'
let g:snips_author = 'Colton'
let g:UltiSnipsSnippetsDir = '~/.vim/custom_snippets'
let g:UltiSnipsSnippetDirectories=['custom_snippets', 'UltiSnips']

" VimWiki

" Disable table navigation via tabs due to conflicts
let g:vimwiki_table_mappings = 0

" set VimWiki path, and use markdown as syntax
let g:vimwiki_list = [{'syntax': 'markdown',
                      \ 'ext': '.md'}]

" Save VimWiki to iCloud if possible
let s:icloud = expand('~/Library/Mobile Documents/com~apple~CloudDocs')
if isdirectory(s:icloud)
    let g:vimwiki_list[0].path = s:icloud . '/vimwiki'
endif

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

" \   'python': ['flake8', 'pydocstyle', 'mypy'],

" Airline
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#coc#enabled = 1
let g:airline_theme='minimalist'

" skip displaying encoding if utf-8
let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'


" Slime
let g:slime_target = 'tmux'
let g:slime_default_config = {'socket_name': 'default', 'target_pane': '{right-of}'}
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
command W w

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

" }}}

" Formatting and Colors {{{


" use foreground colors for gutter icons
highlight ALEErrorSign ctermfg=DarkRed ctermbg=NONE
highlight ALEWarningSign ctermfg=Yellow ctermbg=NONE

" https://codeyarns.com/2011/07/29/vim-set-color-of-colorcolumn/
highlight ColorColumn ctermbg=0


set background=dark

" }}}

" Functions {{{
set signcolumn=yes

function! ToggleSignColumn()
    if &signcolumn ==# 'no'
        let &signcolumn = 'yes'
    else
        let &signcolumn = 'no'
    endif
endfunction

" no background on gutter
highlight clear SignColumn

" }}}

" WIP {{{

if filereadable(expand('~/.vim/db.vim'))
  source ~/.vim/db.vim
endif

" " Load refactored configuration files
" function! LoadConfigs()
"     for config in split(globpath('$HOME/.vim', '*.vim'), '\n')
"         echom 'File: ' . config
"     endfor
" endfunction

augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" }}}

