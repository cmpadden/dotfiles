-- buffer navigation
vim.keymap.set("n", "<Tab>", ":bnext<CR>")
vim.keymap.set("n", "<S-Tab>", ":bprevious<CR>")

-- command navigation
vim.keymap.set("c", "<C-p>", "<Up>")
vim.keymap.set("c", "<C-n>", "<Down>")

-- repeated indentation
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- search visual selection
vim.keymap.set("v", "//", 'y/\\V<C-R>"<CR>')

-- copy to system clipboard
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>y", '"+y')

-- copy active buffer filename to system clipboard
vim.keymap.set("n", "<leader>yf", [[:let @+ = expand('%:t')<CR>]], { silent = true })

-- paste from system clipboard
vim.keymap.set("n", "<leader>p", '"+p')
vim.keymap.set("n", "<leader>P", '"+P')
vim.keymap.set("v", "<leader>p", '"+p')
vim.keymap.set("v", "<leader>P", '"+P')

-- source current Lua file
vim.keymap.set("n", "<leader>ss", ":luafile %<CR>")

-- diagnostics are available whether or not an LSP client is attached
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set(
    "n",
    "<leader>q",
    vim.diagnostic.setloclist,
    { desc = "Diagnostics to location list" }
)

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if not client then
            return
        end

        local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = event.buf, silent = true, desc = desc })
        end

        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("K", vim.lsp.buf.hover, "Hover")
        map("gr", vim.lsp.buf.references, "References")

        if client:supports_method("textDocument/implementation") then
            map("gi", vim.lsp.buf.implementation, "Go to implementation")
        end
        if client:supports_method("textDocument/signatureHelp") then
            map("<C-k>", vim.lsp.buf.signature_help, "Signature help")
        end
        if client:supports_method("textDocument/typeDefinition") then
            map("<leader>D", vim.lsp.buf.type_definition, "Go to type definition")
        end
        if client:supports_method("textDocument/rename") then
            map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
        end
        if client:supports_method("textDocument/codeAction") then
            map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end

        map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add workspace folder")
        map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove workspace folder")
        map("<leader>wl", function()
            vim.print(vim.lsp.buf.list_workspace_folders())
        end, "List workspace folders")
    end,
})
