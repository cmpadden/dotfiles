-----------------------------------------------------------------------------------------
--                                       Plugins                                       --
-----------------------------------------------------------------------------------------

local ensure_packer = function()
  local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require('packer').startup(function(use)

    -- NOTE: use `gx` to open a URL in the web browser

    use 'wbthomason/packer.nvim'                       -- https://github.com/wbthomason/packer.nvim'

    use 'editorconfig/editorconfig-vim'                -- https://github.com/editorconfig/editorconfig-vim
    use 'ggandor/lightspeed.nvim'                      -- https://github.com/ggandor/lightspeed.nvim
    use 'honza/vim-snippets'                           -- https://github.com/honza/vim-snippets
    use { 'iamcco/markdown-preview.nvim',
          run = 'cd app && yarn install',
          cmd = 'MarkdownPreview' }                    -- https://github.com/iamcco/markdown-preview.nvim
    use 'godlygeek/tabular'                            -- https://github.com/godlygeek/tabular
    use 'joosepalviste/nvim-ts-context-commentstring'  -- https://github.com/JoosepAlviste/nvim-ts-context-commentstring
    use 'jpalardy/vim-slime'                           -- https://github.com/jpalardy/vim-slime
    use { 'junegunn/fzf',
          dir = '~/.fzf',
          run = './install --bin' }                    -- https://github.com/junegunn/fzf
    use 'junegunn/fzf.vim'                             -- https://github.com/junegunn/fzf.vim
    use 'junegunn/goyo.vim'                            -- https://github.com/junegunn/goyo.vim
    use 'junegunn/vim-easy-align'                      -- https://github.com/junegunn/vim-easy-align
    use 'lervag/vimtex'                                -- https://github.com/lervag/vimtex
    use 'lewis6991/gitsigns.nvim'                      -- https://github.com/lewis6991/gitsigns.nvim
    use 'norcalli/nvim-colorizer.lua'                  -- https://github.com/norcalli/nvim-colorizer.lua
    use 'nvim-lua/plenary.nvim'                        -- https://github.com/nvim-lua/plenary.nvim
    use { 'nvim-treesitter/nvim-treesitter',
          run = ':TSUpdate' }                          -- https://github.com/nvim-treesitter/nvim-treesitter
    use 'nvim-treesitter/playground'                   -- https://github.com/nvim-treesitter/playground
    use 'preservim/vim-markdown'                       -- https://github.com/preservim/vim-markdown
    use 'tpope/vim-commentary'                         -- https://github.com/tpope/vim-commentary
    use 'tpope/vim-dadbod'                             -- https://github.com/tpope/vim-dadbod
    use 'tpope/vim-fugitive'                           -- https://github.com/tpope/vim-fugitive
    use 'tpope/vim-obsession'                          -- https://github.com/tpope/vim-obsession
    use 'tpope/vim-rhubarb'                            -- https://github.com/tpope/vim-rhubarb
    use 'tpope/vim-surround'                           -- https://github.com/tpope/vim-surround
    use 'Olical/conjure'

    -- color schemes
    use { 'folke/tokyonight.nvim',
          branch = 'main' }                            -- https://github.com/folke/tokyonight.nvim
    use 'bluz71/vim-moonfly-colors'                    -- https://github.com/bluz71/vim-moonfly-colors

    -- lsp
    use 'williamboman/mason.nvim'                      -- https://github.com/williamboman/mason.nvim
    use 'williamboman/mason-lspconfig.nvim'            -- https://github.com/williamboman/mason-lspconfig.nvim
    use 'WhoIsSethDaniel/mason-tool-installer.nvim'    -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
    use 'neovim/nvim-lspconfig'                        -- https://github.com/neovim/nvim-lspconfig
    use 'jose-elias-alvarez/null-ls.nvim'              -- https://github.com/jose-elias-alvarez/null-ls.nvim

    -- completion
    use 'hrsh7th/nvim-cmp'                             -- https://github.com/hrsh7th/nvim-cmp
    use 'hrsh7th/cmp-nvim-lsp'                         -- https://github.com/hrsh7th/cmp-nvim-lsp
    use 'hrsh7th/cmp-buffer'                           -- https://github.com/hrsh7th/cmp-buffer
    use 'hrsh7th/cmp-path'                             -- https://github.com/hrsh7th/cmp-path
    use 'hrsh7th/cmp-cmdline'                          -- https://github.com/hrsh7th/cmp-cmdline
    use 'SirVer/ultisnips'                             -- https://github.com/sirver/UltiSnips
    use 'quangnguyen30192/cmp-nvim-ultisnips'          -- https://github.com/quangnguyen30192/cmp-nvim-ultisnips

    -- personal
    use 'cmpadden/pomodoro.nvim'

    -- Automatically set up your configuration after cloning packer.nvim
    if packer_bootstrap then
        require('packer').sync()
    end
end)

-----------------------------------------------------------------------------------------
--                                Configuration Modules                                --
-----------------------------------------------------------------------------------------

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
