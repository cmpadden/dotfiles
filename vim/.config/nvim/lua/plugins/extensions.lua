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

    -- https://github.com/junegunn/goyo.vim
    vim.g.goyo_height = "100%"
    vim.g.goyo_width = "88"
    vim.keymap.set("n", "<localleader>G", ":Goyo<CR>")
    vim.cmd([[
        function! s:goyo_enter()
          :Gitsigns toggle_signs
          if exists('$TMUX')
            silent !tmux set status off
          endif
        endfunction

        function! s:goyo_leave()
          :Gitsigns toggle_signs
          if exists('$TMUX')
            silent !tmux set status on
          endif
        endfunction

        autocmd! User GoyoEnter nested call <SID>goyo_enter()
        autocmd! User GoyoLeave nested call <SID>goyo_leave()
    ]])

    -- https://github.com/junegunn/vim-easy-align
    vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
    vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

    -- https://github.com/norcalli/nvim-colorizer.lua
    require("colorizer").setup()

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
            "basedpyright",
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

    -- https://github.com/ellisonleao/carbon-now.nvim
    require("carbon-now").setup({
        open_cmd = "open", -- default: xdg-open
        options = {
            drop_shadow_blur = "68px",
            drop_shadow = false,
            drop_shadow_offset_y = "20px",
            font_family = "Hack",
            font_size = "18px",
            line_height = "133%",
            line_numbers = true,
            theme = "shades-of-purple",
            titlebar = "",
            watermark = false,
            width = "680",
            window_theme = "round",
            bg = "black",
        },
    })
    vim.keymap.set("v", "<leader>cn", ":CarbonNow<CR>", { silent = true })

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
