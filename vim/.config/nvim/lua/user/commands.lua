vim.api.nvim_create_user_command(
    "HexEncode",
    ":%!xxd",
    { desc = "Hex encode current file with xxd" }
)

vim.api.nvim_create_user_command(
    "HexDecode",
    ":%!xxd -r",
    { desc = "Hex dump current file with xxd" }
)

vim.api.nvim_create_user_command(
    "W",
    "w",
    { bang = true, desc = "For all those times you accidentally type :W" }
)

vim.api.nvim_create_user_command("ToggleSignColumn", function(input)
    if vim.o.signcolumn == "yes" then
        vim.o.signcolumn = "no"
    else
        vim.o.signcolumn = "yes"
    end
end, { desc = "Toggle the `&signcolumn`" })

vim.api.nvim_create_user_command(
    "Notes",
    ":e ~/notes.md.asc",
    { bang = false, desc = "Edit notes.md" }
)

-- LSP info command (replacement for nvim-lspconfig's :LspInfo)
vim.api.nvim_create_user_command("LspInfo", function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then
        print("No LSP clients attached to this buffer")
        return
    end

    print("LSP clients attached to buffer " .. vim.api.nvim_get_current_buf() .. ":")
    for _, client in ipairs(clients) do
        print(string.format("  • %s (id: %d)", client.name, client.id))
        if client.server_capabilities then
            print(string.format("    Root: %s", client.root_dir or "N/A"))
            if client.server_info and client.server_info.version then
                print(string.format("    Version: %s", client.server_info.version))
            end
        end
    end
    print("\nFor full health check, run: :checkhealth vim.lsp")
end, { desc = "Show LSP client info for current buffer" })
