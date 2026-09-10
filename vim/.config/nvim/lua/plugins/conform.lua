local M = {}

function M.setup()
    -- https://github.com/stevearc/conform.nvim
    require("conform").setup({
        formatters_by_ft = {
            ["*"] = { "codespell", "trim_whitespace" },
            javascript = { "oxfmt" },
            javascriptreact = { "oxfmt" },
            lua = { "stylua" },
            markdown = { "oxfmt" },
            rust = { "rustfmt", lsp_format = "fallback" },
            sh = { "shfmt" },
            sql = { "sqlfluff" },
            typescript = { "oxfmt" },
            typescriptreact = { "oxfmt" },
            vue = { "oxfmt" },
        },
        default_format_opts = {
            lsp_format = "fallback",
        },
        formatters = {
            sqlfluff = {
                prepend_args = { "--dialect", "snowflake" },
            },
        },
    })
    vim.keymap.set("", "<leader>f", function()
        require("conform").format({ async = true })
    end, { desc = "Format buffer" })
end

return M
