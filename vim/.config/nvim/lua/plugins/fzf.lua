local M = {}

function M.setup()
    -- https://github.com/ibhagwan/fzf-lua
    vim.keymap.set("n", "<C-f>f", require("fzf-lua").files)
    vim.keymap.set("n", "<C-f>n", require("fzf-lua").git_files)
    vim.keymap.set("n", "<C-f>l", require("fzf-lua").blines)
    vim.keymap.set("n", "<C-f>g", require("fzf-lua").live_grep_native)
    vim.keymap.set("n", "<C-f>h", require("fzf-lua").help_tags)
    vim.keymap.set("n", "<C-f>c", require("fzf-lua").git_bcommits)
    vim.keymap.set("n", "<C-f>b", require("fzf-lua").buffers)
    vim.keymap.set("n", "<C-f>d", require("fzf-lua").diagnostics_document)
    require("fzf-lua").setup({
        winopts = {
            height = 0.50,
            width = 0.85,
            preview = {
                title = false,
                layout = "vertical",
                scrollbar = false,
            },
        },
    })
end

return M
