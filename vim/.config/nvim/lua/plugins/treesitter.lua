local ensure_installed = {
    "bash",
    "css",
    "diff",
    "gitignore",
    "hcl",
    "html",
    "http",
    "javascript",
    "jsdoc",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "sql",
    "toml",
    "typescript",
    "vue",
    "yaml",
}

local M = {}

function M.setup()
    require("nvim-treesitter").install(ensure_installed)

    local group = vim.api.nvim_create_augroup("user_treesitter", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.api.nvim_buf_line_count(args.buf) <= 10000 then
                pcall(vim.treesitter.start, args.buf)
            end
        end,
    })

    -- Neovim 0.12 is still tripping over markdown injection parsing in this config.
    -- Keep markdown Treesitter highlighting, but disable nested language injections.
    vim.treesitter.query.set("markdown", "injections", "")
    vim.treesitter.query.set("markdown_inline", "injections", "")
end

return M
