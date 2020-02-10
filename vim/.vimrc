" For a paranoia.
" Normally `:set nocp` is not needed, because it is done automatically
" when .vimrc is found.
if &compatible
  " `:set nocp` has many side effects. Therefore this should be done
  " only when 'compatible' is set.
  set nocompatible
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Plugins                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


if empty(glob('~/.vim/pack/minpac/opt/minpac'))
    silent !git clone https://github.com/k-takata/minpac.git ~/.vim/pack/minpac/opt/minpac
    " augroup startupVimEnter
    "     autocmd!
    "     autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    " augroup END
endif

if exists('*minpac#init')

    " minpac
    call minpac#init()
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " Additional plugins
    call minpac#add('SirVer/ultisnips')
    call minpac#add('editorconfig/editorconfig-vim')
    call minpac#add('honza/vim-snippets')
    call minpac#add('junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' })
    call minpac#add('junegunn/fzf.vim')
    call minpac#add('junegunn/vim-easy-align')
    call minpac#add('plytophogy/vim-virtualenv')
    call minpac#add('sheerun/vim-polyglot')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-dadbod')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('tpope/vim-surround')
    call minpac#add('tpope/vim-vinegar')
    call minpac#add('vim-airline/vim-airline')
    call minpac#add('vim-airline/vim-airline-themes')
    call minpac#add('vimwiki/vimwiki')
    call minpac#add('w0rp/ale')


    call minpac#add('neoclide/coc.nvim', {'branch': 'release'})
    " let g:coc_global_extensions = [
    "       \ 'coc-ultisnips',
    "       \ 'coc-python',
    "       \ ]
    " :CocInstall coc-metals

    " requires vim 8.1
    if v:version >= 801
        call minpac#add('iamcco/markdown-preview.nvim', { 'do': {-> mkdp#util#install()} })
    endif

endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Mappings                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let mapleader = "\<Space>"

" fzf
nnoremap <c-f>b :Buffers<CR>
nnoremap <c-f>c :Colors<CR>
nnoremap <c-f>g :Ag<CR>
nnoremap <c-f>t :Tags<CR>
nnoremap <c-f>f :GFiles<CR>
nnoremap <c-f>h :Helptags<CR>
nnoremap <c-f>l :Lines<CR>
nnoremap <c-f>n :Files<CR>
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

nmap <leader>rn <Plug>(coc-rename)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Variables                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Snippets
let g:UltiSnipsJumpForwardTrigger  = '<c-n>'
let g:UltiSnipsJumpBackwardTrigger = '<c-p>'
let g:UltiSnipsEditSplit = 'vertical'
let g:snips_author = 'Colton'

" I don't care what people say, these settings are not intuitive...
let g:UltiSnipsSnippetsDir = '~/.vim/custom_snippets'
let g:UltiSnipsSnippetDirectories=['custom_snippets', 'UltiSnips']

" Wiki (table tabs prevent ultisnips)
let g:vimwiki_table_mappings = 0

" Ale
let g:ale_sign_column_always = 0
let g:ale_sign_error = '•'
let g:ale_sign_warning = '•'

let g:airline#extensions#ale#enabled = 1
let g:ale_fix_on_save = 0

let g:ale_fixers = {
\   '*':      ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8', 'yapf'],
\   'yaml':   ['prettier'],
\   'markdown': ['prettier'],
\}

let g:ale_linters = {
\   'python': ['flake8', 'pydocstyle'],
\   'markdown': ['proselint', 'mdl'],
\}

" airline
let g:airline_theme='minimalist'

" coc
let g:airline#extensions#coc#enabled = 1

" completor
let g:completor_python_binary = '/usr/local/bin/python3'

" slime
let g:slime_target = 'tmux'
let g:slime_default_config = {'socket_name': 'default', 'target_pane': '{right-of}'}
let g:slime_dont_ask_default = 1

let g:EditorConfig_exclude_patterns = ['fugitive://.\*', 'scp://.\*']

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Settings                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype indent plugin on

syntax on
set background=light

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

" fold outer-most indents for python files
" augroup pythonFolding
"     autocmd!
"     autocmd Filetype python set foldmethod=indent
"     autocmd Filetype python set foldnestmax=1
" augroup END

" hide scrollbars in GUI
if has('gui')
    set guioptions-=r
    set guioptions-=L
endif

set dictionary=/usr/share/dict/words

" I keep typing :W instead of :w and it's driving me insane...
command W w

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Commands                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

command! Hex :%!xxd
command! Dehex :%!xxd -r

" Define user commands for updating/cleaning the plugins.  Each of them loads
" minpac, reloads .vimrc to register the information of plugins, then performs
" the task.
command! PackUpdate packadd minpac | source $MYVIMRC | call minpac#update('', {'do': 'call minpac#status()'})
command! PackClean  packadd minpac | source $MYVIMRC | call minpac#clean()
command! PackStatus packadd minpac | source $MYVIMRC | call minpac#status()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                Auto Commands                                 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" after opening `help` files, move them to the right
augroup helpFileType
    autocmd!
    autocmd FileType help wincmd L
augroup END


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Theming                                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" small tweak to colors - will eventually move to a separate file

" no background on gutter
highlight clear SignColumn

" use foreground colors for gutter icons
highlight ALEErrorSign ctermfg=DarkRed ctermbg=NONE
highlight ALEWarningSign ctermfg=Yellow ctermbg=NONE


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Functions                                  "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! ToggleSignColumn()
    if &signcolumn ==# 'no'
        let &signcolumn = 'yes'
    else
        let &signcolumn = 'no'
    endif
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                   Private                                   "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if filereadable(expand('~/.vim/db.vim'))
  source ~/.vim/db.vim
endif
