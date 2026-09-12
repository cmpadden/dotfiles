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
    { src = github .. "Mofiqul/dracula.nvim" },
    { src = "https://codeberg.org/andyg/leap.nvim" },
    { src = github .. "ibhagwan/fzf-lua" },
    { src = github .. "jpalardy/vim-slime" },
    { src = github .. "junegunn/vim-easy-align" },
    { src = github .. "lewis6991/gitsigns.nvim" },
    { src = github .. "moyiz/blink-emoji.nvim" },
    { src = github .. "nvim-treesitter/nvim-treesitter" },
    { src = github .. "saghen/blink.cmp", version = vim.version.range("1") },
    { src = github .. "sindrets/diffview.nvim" },
    { src = github .. "stevearc/conform.nvim" },
    { src = github .. "tpope/vim-fugitive" },
    { src = github .. "tpope/vim-surround" },
}, { confirm = false })

vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
end, { desc = "Update all vim.pack plugins" })

require("plugins.cmp").setup()
require("plugins.colors").setup()
require("plugins.conform").setup()
require("plugins.diffview").setup()
require("plugins.editing").setup()
require("plugins.fzf").setup()
require("plugins.gitsigns").setup()
require("plugins.treesitter").setup()
