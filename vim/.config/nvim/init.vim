""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                       Plugins                                        "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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
Plug 'ggandor/lightspeed.nvim'                                           " https://github.com/ggandor/lightspeed.nvim
Plug 'heavenshell/vim-jsdoc', { 'do': 'make install' }                   " https://github.com/heavenshell/vim-jsdoc
Plug 'honza/vim-snippets'                                                " https://github.com/honza/vim-snippets
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  } " https://github.com/iamcco/markdown-preview.nvim
Plug 'joosepalviste/nvim-ts-context-commentstring'                       " https://github.com/JoosepAlviste/nvim-ts-context-commentstring
Plug 'jpalardy/vim-slime'                                                " https://github.com/jpalardy/vim-slime
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }        " https://github.com/junegunn/fzf
Plug 'junegunn/fzf.vim'                                                  " https://github.com/junegunn/fzf.vim
Plug 'junegunn/goyo.vim'                                                 " https://github.com/junegunn/goyo.vim
Plug 'junegunn/vim-easy-align'                                           " https://github.com/junegunn/vim-easy-align
Plug 'lervag/vimtex'                                                     " https://github.com/lervag/vimtex
Plug 'lewis6991/gitsigns.nvim'                                           " https://github.com/lewis6991/gitsigns.nvim
Plug 'norcalli/nvim-colorizer.lua'                                       " https://github.com/norcalli/nvim-colorizer.lua
Plug 'nvim-lua/plenary.nvim'                                             " https://github.com/nvim-lua/plenary.nvim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}              " https://github.com/nvim-treesitter/nvim-treesitter
Plug 'nvim-treesitter/playground'                                        " https://github.com/nvim-treesitter/playground
Plug 'preservim/vim-markdown'                                            " https://github.com/preservim/vim-markdown
Plug 'tpope/vim-commentary'                                              " https://github.com/tpope/vim-commentary
Plug 'tpope/vim-dadbod'                                                  " https://github.com/tpope/vim-dadbod
Plug 'tpope/vim-fugitive'                                                " https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-obsession'                                               " https://github.com/tpope/vim-obsession
Plug 'tpope/vim-rhubarb'                                                 " https://github.com/tpope/vim-rhubarb
Plug 'tpope/vim-surround'                                                " https://github.com/tpope/vim-surround
Plug 'vim-airline/vim-airline'                                           " https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline-themes'                                    " https://github.com/vim-airline/vim-airline-themes

" color schemes
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }                       " https://github.com/folke/tokyonight.nvim
Plug 'bluz71/vim-moonfly-colors'                                         " https://github.com/bluz71/vim-moonfly-colors

" LSP
Plug 'williamboman/mason.nvim'                                           " https://github.com/williamboman/mason.nvim
Plug 'williamboman/mason-lspconfig.nvim'                                 " https://github.com/williamboman/mason-lspconfig.nvim
Plug 'WhoIsSethDaniel/mason-tool-installer.nvim'                         " https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
Plug 'neovim/nvim-lspconfig'                                             " https://github.com/neovim/nvim-lspconfig
Plug 'jose-elias-alvarez/null-ls.nvim'                                   " https://github.com/jose-elias-alvarez/null-ls.nvim

" Completion
Plug 'hrsh7th/nvim-cmp'                                                  " https://github.com/hrsh7th/nvim-cmp
Plug 'hrsh7th/cmp-nvim-lsp'                                              " https://github.com/hrsh7th/cmp-nvim-lsp
Plug 'hrsh7th/cmp-buffer'                                                " https://github.com/hrsh7th/cmp-buffer
Plug 'hrsh7th/cmp-path'                                                  " https://github.com/hrsh7th/cmp-path
Plug 'hrsh7th/cmp-cmdline'                                               " https://github.com/hrsh7th/cmp-cmdline
Plug 'SirVer/ultisnips'                                                  " https://github.com/sirver/UltiSnips
Plug 'quangnguyen30192/cmp-nvim-ultisnips'                               " https://github.com/quangnguyen30192/cmp-nvim-ultisnips

" Personal
Plug 'cmpadden/pomodoro.nvim'

" Initialize plugin system
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                         Lua                                          "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

lua require('user.globals')
lua require('user.options')
lua require('user.keymap')
lua require('user.plugins')
lua require('user.commands')
lua require('user.augroups')

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                         Work                                         "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if filereadable(expand("$HOME") . "/.config/nvim/work.vim")
    runtime work.vim
endif
