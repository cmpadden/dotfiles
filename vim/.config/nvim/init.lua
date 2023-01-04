-----------------------------------------------------------------------------------------
--                                       Plugins                                       --
-----------------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local plugins = {

    -- main
    { 'editorconfig/editorconfig-vim' },
    { 'ggandor/lightspeed.nvim' },
    { 'iamcco/markdown-preview.nvim', build = 'cd app && yarn install', cmd = 'MarkdownPreview' },
    { 'godlygeek/tabular' },
    { 'joosepalviste/nvim-ts-context-commentstring' },
    { 'jpalardy/vim-slime' },
    { 'junegunn/fzf', dir = '~/.fzf', build = './install --bin' },
    { 'junegunn/fzf.vim' },
    { 'ibhagwan/fzf-lua' },
    { 'junegunn/goyo.vim' },
    { 'junegunn/vim-easy-align' },
    { 'lervag/vimtex' },
    { 'lewis6991/gitsigns.nvim' },
    { 'norcalli/nvim-colorizer.lua' },
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
    { 'nvim-treesitter/playground' },
    { 'preservim/vim-markdown' },
    { 'tpope/vim-commentary' },
    { 'tpope/vim-dadbod' },
    { 'tpope/vim-fugitive' },
    { 'tpope/vim-obsession' },
    { 'tpope/vim-rhubarb' },
    { 'tpope/vim-surround' },

    -- color schemes
    {
      'folke/tokyonight.nvim',
      lazy = false, -- make sure we load this during startup if it is your main colorscheme
      priority = 1000, -- make sure to load this before all the other start plugins
      config = function()
        vim.opt.signcolumn = "yes"
        vim.opt.termguicolors = true -- support true colors
        vim.cmd("colorscheme tokyonight-night")
      end,
    },

    -- lsp
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { 'WhoIsSethDaniel/mason-tool-installer.nvim' },
    { 'neovim/nvim-lspconfig' },
    { 'jose-elias-alvarez/null-ls.nvim' },

    -- completion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },

    -- snippets
    { 'L3MON4D3/LuaSnip' },
    { 'saadparwaiz1/cmp_luasnip' },

    -- personal
    { 'cmpadden/pomodoro.nvim' },


}

require("lazy").setup(plugins)


-----------------------------------------------------------------------------------------
--                                Configuration Modules                                --
-----------------------------------------------------------------------------------------


-- TODO: plugins configurations will move into `plugin/` modules as used in lazy.nvim

require('user.globals')
require('user.options')
require('user.keymap')
require('user.plugins')
require('user.commands')
require('user.augroups')

vim.cmd([[
  if filereadable(expand("$HOME") . "/.config/nvim/work.vim")
    runtime work.vim
  endif
]])
