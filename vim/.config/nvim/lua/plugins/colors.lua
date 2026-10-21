local M = {}

function M.setup()
    vim.o.termguicolors = true

    -- Choose once at startup; macOS leaves AppleInterfaceStyle unset in light mode.
    -- Elsewhere, keep Neovim's detected/default background preference.
    if vim.fn.has("macunix") == 1 then
        local appearance = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })
        vim.o.background = appearance:match("Dark") and "dark" or "light"
    end

    if vim.o.background == "light" then
        vim.cmd.colorscheme("catppuccin-latte")
        return
    end

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
