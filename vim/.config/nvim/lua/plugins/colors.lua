local M = {}

function M.setup()
    vim.o.termguicolors = true

    require("dracula").setup({
        colors = {
            bg = "#212121",
            fg = "#f8f8f2",
            selection = "#3a3a46",
            red = "#ff5555",
            bright_red = "#ff6e6e",
            green = "#50fa7b",
            bright_green = "#69ff94",
            yellow = "#ffcb6b",
            purple = "#c792ea",
            cyan = "#8be9fd",
            bright_cyan = "#a4ffff",
            menu = "#21222c",
            visual = "#3e4452",
            black = "#21222c",
        },
    })
    vim.cmd.colorscheme("dracula")
end

return M
