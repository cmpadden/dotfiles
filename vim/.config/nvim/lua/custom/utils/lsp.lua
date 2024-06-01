local M = {}

-- `on_attach` to map keys after language server attaches to the current buffer
-- See `:help vim.lsp.*`
-- See `:help vim.diagnostic.*`
M.on_attach = function(client, bufnr)
    local opts = { noremap = true, silent = true }

    -- Avoid using formatting capability for `tsserver`, and instead use `eslint` or
    -- `prettier`.
    if client.name == "tsserver" then
        client.resolved_capabilities.document_formatting = false
        client.resolved_capabilities.document_range_formatting = false
    end

    -- Global Bindings - Diagnostics

    vim.keymap.set("n", "<space>d", vim.diagnostic.open_float, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)

    -- Buffer Bindings

    local opts_buffer = { noremap = true, silent = true, buffer = bufnr }

    if client.supports_method("textDocument/declaration") then
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts_buffer)
    end

    if client.supports_method("textDocument/definition") then
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts_buffer)
    end

    if client.supports_method("textDocument/hover") then
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts_buffer)
    end

    if client.supports_method("textDocument/implementation") then
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts_buffer)
    end

    if client.supports_method("textDocument/signatureHelp") then
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts_buffer)
    end

    if client.supports_method("textDocument/typeDefinition") then
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts_buffer)
    end

    if client.supports_method("textDocument/rename") then
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts_buffer)
    end

    if client.supports_method("textDocument/codeAction") then
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts_buffer)
    end

    if client.supports_method("textDocument/references") then
        vim.keymap.set("n", "gr", vim.lsp.buf.references, opts_buffer)
    end

    if client.supports_method("textDocument/formatting") then
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
        end, opts_buffer)
    end

    -- if client.supports_method("textDocument/workspaceEdit") then
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts_buffer)

    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts_buffer)

    vim.keymap.set("n", "<space>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts_buffer)
end

return M
