" Share Vim runtime path
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" Neovim requires `pynvim` to be installed on the host program. This can be
" done by issuing the following command:
" PIP_REQUIRE_VIRTUALENV=false /usr/bin/python3 -m pip install --user pynvim

if filereadable('/usr/local/bin/python3')
    " MacOS
    let g:python3_host_prog = '/usr/local/bin/python3'
elseif filereadable('/usr/local/bin/python3')
    " Linux
    let g:python3_host_prog = '/usr/bin/python3'
endif



source ~/.vimrc
