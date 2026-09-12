-- Native Neovim package configuration.

if not vim.pack then
    error("vim.pack requires Neovim 0.12 or later")
end

local github = "https://github.com/"

vim.api.nvim_create_autocmd("PackChanged", {
    callback = function(event)
        if event.data.kind ~= "update" then
            return
        end

        local commands = {
            ["mason.nvim"] = "MasonUpdate",
            ["nvim-treesitter"] = "TSUpdate",
        }
        local command = commands[event.data.spec.name]
        if not command then
            return
        end

        vim.schedule(function()
            vim.cmd.packadd(event.data.spec.name)
            vim.cmd(command)
        end)
    end,
})

vim.pack.add({
    { src = github .. "EdenEast/nightfox.nvim" },
    { src = github .. "WhoIsSethDaniel/mason-tool-installer.nvim" },
    { src = "https://codeberg.org/andyg/leap.nvim" },
    { src = github .. "goolord/alpha-nvim" },
    { src = github .. "ibhagwan/fzf-lua" },
    { src = github .. "jpalardy/vim-slime" },
    { src = github .. "junegunn/vim-easy-align" },
    { src = github .. "lewis6991/gitsigns.nvim" },
    { src = github .. "moyiz/blink-emoji.nvim" },
    { src = github .. "nvim-treesitter/nvim-treesitter" },
    { src = github .. "saghen/blink.cmp", version = vim.version.range("1.0") },
    { src = github .. "sindrets/diffview.nvim" },
    { src = github .. "stevearc/conform.nvim" },
    { src = github .. "tpope/vim-fugitive" },
    { src = github .. "tpope/vim-surround" },
    { src = github .. "williamboman/mason.nvim" },
}, { confirm = false })

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update all vim.pack plugins" })

require("plugins.colors").setup()
require("plugins.cmp").setup()
require("plugins.treesitter").setup()
require("plugins.extensions").setup()
require("plugins.alpha").setup()
