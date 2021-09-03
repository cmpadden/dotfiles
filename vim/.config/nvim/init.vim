" Share Vim runtime path
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Set `python3` host program to use version from `homebrew`
" > brew link python@3.8
" > /usr/local/bin/python3 -m pip install --user --upgrade pip --user
" > /usr/local/bin/python3 -m pip install --user pynvim

if filereadable('/usr/local/bin/python3')
    " MacOS
    let g:python3_host_prog = '/usr/local/bin/python3'
elseif filereadable('/usr/local/bin/python3')
    " Linux
    let g:python3_host_prog = '/usr/bin/python3'
endif



source ~/.vimrc
