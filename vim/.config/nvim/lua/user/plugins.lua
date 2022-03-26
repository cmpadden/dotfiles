-------------------------------------------------------------------------------------------------------------------------
--                                                       null-ls                                                       --
-------------------------------------------------------------------------------------------------------------------------

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
    return
end
null_ls.setup({
    sources = {
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.completion.spell,
        null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.diagnostics.pydocstyle,
        null_ls.builtins.formatting.autopep8,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.reorder_python_imports,
        null_ls.builtins.formatting.stylua,
    },
})

-------------------------------------------------------------------------------------------------------------------------
--                                                      gitsigns                                                       --
-------------------------------------------------------------------------------------------------------------------------

local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
if not gitsigns_ok then
    return
end
gitsigns.setup{
  on_attach = function(bufnr)
    local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', {noremap = true, silent = true}, opts or {})
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    end

    -- Navigation
    map('n', ']g', "&diff ? ']g' : '<cmd>Gitsigns next_hunk<CR>'", {expr=true})
    map('n', '[g', "&diff ? '[g' : '<cmd>Gitsigns prev_hunk<CR>'", {expr=true})

    -- Actions
    map('n', '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map('v', '<leader>hs', ':Gitsigns stage_hunk<CR>')
    map('n', '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('v', '<leader>hr', ':Gitsigns reset_hunk<CR>')
    map('n', '<leader>hS', '<cmd>Gitsigns stage_buffer<CR>')
    map('n', '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<CR>')
    map('n', '<leader>hR', '<cmd>Gitsigns reset_buffer<CR>')
    map('n', '<leader>hp', '<cmd>Gitsigns preview_hunk<CR>')
    map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
    map('n', '<leader>tb', '<cmd>Gitsigns toggle_current_line_blame<CR>')
    map('n', '<leader>hd', '<cmd>Gitsigns diffthis<CR>')
    map('n', '<leader>hD', '<cmd>lua require"gitsigns".diffthis("~")<CR>')
    map('n', '<leader>td', '<cmd>Gitsigns toggle_deleted<CR>')

    -- Text object
    map('o', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
    map('x', 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-------------------------------------------------------------------------------------------------------------------------
--                                                      colorizer                                                      --
-------------------------------------------------------------------------------------------------------------------------

local colorizer_ok, colorizer = pcall(require, "colorizer")
if not colorizer_ok then
    return
end
colorizer.setup()
