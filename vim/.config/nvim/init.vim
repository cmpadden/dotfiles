set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath

" PIP_REQUIRE_VIRTUALENV=false /usr/bin/python3 -m pip install --user pynvim

if filereadable('/usr/local/bin/python3')
    let g:python3_host_prog = '/usr/local/bin/python3'
elseif filereadable('/usr/local/bin/python3')
    let g:python3_host_prog = '/usr/bin/python3'
endif

source ~/.vimrc
