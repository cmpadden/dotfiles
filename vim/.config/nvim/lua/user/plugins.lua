-----------------------------------------------------------------------------------------
--                                        mason                                        --
-----------------------------------------------------------------------------------------

require("mason").setup()

-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
require("mason-lspconfig").setup({
    ensure_installed = {
        "bashls", -- Bash
        "pyright", -- Python
        "sumneko_lua", -- Lua
        "tailwindcss", -- Tailwind
        "tsserver", -- Typescript
    },
})

-- https://github.com/williamboman/mason.nvim/issues/103#issuecomment-1190423009
require("mason-tool-installer").setup({
    ensure_installed = {
        "black",
        "flake8",
        "isort",
        "prettier",
        "pydocstyle",
        "shellcheck",
        "shfmt",
        "sqlfluff",
        "stylua",
        "vale",
    },
    run_on_start = false,
})

-----------------------------------------------------------------------------------------
--                                     treesitter                                      --
-----------------------------------------------------------------------------------------

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "hcl",
        "lua",
        "python",
        "typescript",
    },
    context_commentstring = {
        enable = true,
    },
})

-----------------------------------------------------------------------------------------
--                                         LSP                                         --
-----------------------------------------------------------------------------------------

local cmp = require("cmp")
local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
local lspconfig = require("lspconfig")

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    mapping = {
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-l>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        }),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-e>"] = cmp.mapping({
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        }),
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "ultisnips" },
        { name = "buffer" },
    }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = "buffer" },
    }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
    sources = {
        { name = "buffer" },
    },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

-- Mappings
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<space>e", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
vim.api.nvim_set_keymap("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
vim.api.nvim_set_keymap("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>", opts)
vim.api.nvim_set_keymap("n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    -- https://github.com/LunarVim/Neovim-from-scratch/blob/7a082a3306b27d59257ce9bc826ab4dc64f69854/lua/user/lsp/handlers.lua#L88
    if client.name == "tsserver" then
        client.resolved_capabilities.document_formatting = false
    end

    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "<space>wl",
        "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
        opts
    )
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

local servers = {
    "bashls",
    "eslint",
    "html",
    "jsonls",
    "pyright",
    "rust_analyzer",
    "sumneko_lua",
    "tailwindcss",
    "tsserver",
    "vuels",
}
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        flags = {
            debounce_text_changes = 150,
        },
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                },
                diagnostics = {
                    globals = { "vim", "hs", "spoon" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true), -- Make the server aware of Neovim runtime files
                },
                telemetry = {
                    enable = false, -- Do not send telemetry data containing a randomized but unique identifier
                },
            },
        },
    })
end

-----------------------------------------------------------------------------------------
--                                       null-ls                                       --
-----------------------------------------------------------------------------------------

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end

local code_actions = null_ls.builtins.code_actions
local completion = null_ls.builtins.completion
local diagnostics = null_ls.builtins.diagnostics
local formatting = null_ls.builtins.formatting

null_ls.setup({
    sources = {
        code_actions.shellcheck,
        diagnostics.shellcheck,
        diagnostics.sqlfluff.with({ extra_args = { "--dialect", "snowflake" } }),
        completion.spell,
        diagnostics.vale,
        diagnostics.flake8.with({ extra_args = { "--max-line-length", "88" } }),
        diagnostics.pydocstyle,
        formatting.black,
        formatting.sqlfluff,
        formatting.sqlfluff.with({ extra_args = { "--dialect", "snowflake" } }),
        formatting.prettier,
        formatting.isort,
        formatting.shfmt.with({ extra_args = { "-i", "4" } }),
        formatting.stylua.with({ extra_args = { "--indent-type", "Spaces" } }),
    },
    on_attach = function(_, bufnr)
        vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", {})
    end,
})

-----------------------------------------------------------------------------------------
--                                      gitsigns                                       --
-----------------------------------------------------------------------------------------

local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if not gitsigns_ok then
    return
end
gitsigns.setup({
    on_attach = function(bufnr)
        local function map(mode, lhs, rhs, opts)
            opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
            vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end

        -- Navigation
        map("n", "]g", "&diff ? ']g' : '<cmd>Gitsigns next_hunk<CR>'", { expr = true })
        map("n", "[g", "&diff ? '[g' : '<cmd>Gitsigns prev_hunk<CR>'", { expr = true })

        -- Actions
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
        map("n", "<leader>hD", '<cmd>lua require"gitsigns".diffthis("~")<CR>')
        map("n", "<leader>td", "<cmd>Gitsigns toggle_deleted<CR>")

        -- Text object
        map("o", "ih", ":<C-U>Gitsigns select_hunk<CR>")
        map("x", "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
})

-----------------------------------------------------------------------------------------
--                                      colorizer                                      --
-----------------------------------------------------------------------------------------

local colorizer_ok, colorizer = pcall(require, "colorizer")
if not colorizer_ok then
    return
end
colorizer.setup()

-----------------------------------------------------------------------------------------
--                                      Personal                                       --
-----------------------------------------------------------------------------------------

local pomodoro_ok, pomodoro = pcall(require, "pomodoro")
if not pomodoro_ok then
    return
end
pomodoro.setup()
