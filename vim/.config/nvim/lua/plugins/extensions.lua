--------------------------------------------------------------------------------
--                                 Extensions                                 --
--------------------------------------------------------------------------------

local M = {}

function M.setup()
    -- https://github.com/jpalardy/vim-slime
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_bracketed_paste = 1

    -- https://codeberg.org/andyg/leap.nvim
    vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
    vim.keymap.set("n", "S", "<Plug>(leap-from-window)")

    -- https://github.com/junegunn/vim-easy-align
    vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
    vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

    -- https://github.com/williamboman/mason.nvim
    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗",
            },
        },
    })

    -- https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
    require("mason-tool-installer").setup({
        ensure_installed = {
            -- LSP servers configured in lua/lsp/servers/
            "bash-language-server",
            "eslint-lsp",
            "html-lsp",
            "json-lsp",
            "lua-language-server",
            "ruff",
            "rust-analyzer",
            "tailwindcss-language-server",
            "vtsls",
            "yaml-language-server",

            -- Formatters and linters
            "codespell",
            "oxfmt",
            "shfmt",
            "sqlfluff",
            "stylua",
        },
        run_on_start = true,
    })

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

    -- https://github.com/lewis6991/gitsigns.nvim
    require("gitsigns").setup({
        on_attach = function(bufnr)
            local function map(mode, lhs, rhs, opts)
                opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
                vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
            end

            map("n", "]g", "&diff ? ']g' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
            map("n", "[g", "&diff ? '[g' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

            map("n", "<leader>hs", ":Gitsigns stage_hunk<CR>")
            map("v", "<leader>hs", ":Gitsigns stage_hunk<CR>")
            map("n", "<leader>hr", ":Gitsigns reset_hunk<CR>")
            map("v", "<leader>hr", ":Gitsigns reset_hunk<CR>")
            map("n", "<leader>hS", "<cmd>Gitsigns stage_buffer<CR>")
            map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>")
            map("n", "<leader>hR", "<cmd>Gitsigns reset_buffer<CR>")
            map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>")
            map("n", "<leader>hb", '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
            map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<CR>")
            map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>")
            map("n", "<leader>hD", '<cmd>Gitsigns diffthis("~")<CR>')
            map("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

            map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
            map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
    })
end

return M
