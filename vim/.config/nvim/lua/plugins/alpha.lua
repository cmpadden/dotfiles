-- REFERENCES
--
--     https://github.com/goolord/alpha-nvim
--     https://github.com/LazyVim/LazyVim/blob/592074ad802be2462306d3991024f350571dfab2/lua/lazyvim/plugins/ui.lua#L261C1-L283C9
--

--- Wraps `text` into lines of specified width.
--
-- @param text (string): The text to be wrapped.
-- @param width (number|nil): The maximum line width. Defaults to 50 if nil.
-- @return (table): A table containing the wrapped lines.
local function wrap(text, width)
    width = width or 50
    local lines = {}
    for i = 1, #text, width do
        local line = text:sub(i, i + width - 1)
        line = vim.trim(line, " ")
        table.insert(lines, line)
    end
    return lines
end

local BANNER_TEXT =
    "All moments, past, present, and future, always have existed, always will exist. The Tralfamadorians can look at all the different moments just the way we can look at a stretch of the Rocky Mountains, for instance. It is just an illusion we have here on Earth that one moment follows another one, like beads on a string, and that once a moment is gone it is gone forever."

local M = {}

function M.setup()
    local path_ok, dashboard = pcall(require, "alpha.themes.dashboard")
    if not path_ok then
        return
    end

    dashboard.section.header.val = wrap(BANNER_TEXT)
    dashboard.section.buttons.val = {
        dashboard.button("i", "New file", ":ene <BAR> startinsert <CR>"),
        dashboard.button("f", "Find file", ":FzfLua files<CR>"),
        dashboard.button("s", "Settings", ":e $MYVIMRC | :cd %:p:h<CR>"),
        dashboard.button("q", "Quit", ":qa<CR>"),
    }

    require("alpha").setup(dashboard.opts)
end

return M
