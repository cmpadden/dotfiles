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
    call minpac#add('aklt/plantuml-syntax')
    call minpac#add('editorconfig/editorconfig-vim')
    call minpac#add('honza/vim-snippets')
    call minpac#add('junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' })
    call minpac#add('junegunn/fzf.vim')
    call minpac#add('junegunn/vim-easy-align')
    call minpac#add('maralla/completor.vim')
    call minpac#add('plytophogy/vim-virtualenv')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('tpope/vim-surround')
    call minpac#add('tpope/vim-vinegar')
    call minpac#add('vim-airline/vim-airline')
    call minpac#add('vim-airline/vim-airline-themes')
    call minpac#add('vimwiki/vimwiki')
    call minpac#add('w0rp/ale')

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
nnoremap <c-f>a :Ag<CR>
nnoremap <c-f>g :Ag<CR>
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


" Easily run Python code
augroup pythonMappings
    autocmd!
    autocmd Filetype python nnoremap <buffer> <F5> :exec '!python' shellescape(@%, 1)<cr>
augroup END

" Completor
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<cr>"
noremap <silent> <leader>gd :call completor#do('definition')<CR>
noremap <silent> <leader>gc :call completor#do('doc')<CR>
noremap <silent> <leader>gh :call completor#do('hover')<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                  Variables                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Snippets
let g:UltiSnipsJumpForwardTrigger  = '<c-n>'
let g:UltiSnipsJumpBackwardTrigger = '<c-p>'
let g:UltiSnipsEditSplit = 'vertical'

" Wiki (table tabs prevent ultisnips)
let g:vimwiki_table_mappings = 0

" Ale
let g:ale_sign_column_always = 1
let g:airline#extensions#ale#enabled = 1
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*':      ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['black', 'isort'],
\   'yaml':   ['prettier'],
\}

" airline
let g:airline_theme='minimalist'

" completor
let g:completor_python_binary = '/usr/local/bin/python3'


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
set textwidth=80

set backspace=2


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
