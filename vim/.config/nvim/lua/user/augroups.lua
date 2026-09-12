local function markdown_fold_expr(lnum)
    local level = vim.fn.getline(lnum):match("^(#+) ")
    return level and ">" .. #level or "="
end

local function markdown_fold_text()
    local line = vim.fn.getline(vim.v.foldstart)
    local line_count = vim.v.foldend - vim.v.foldstart + 1
    return string.format("%s [%d]", line, line_count)
end

local spell_checking = vim.api.nvim_create_augroup("spell_checking", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = spell_checking,
    pattern = { "markdown", "vimwiki" },
    command = "setlocal spell",
})

local filetypes = vim.api.nvim_create_augroup("filetypes", { clear = true })
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = filetypes,
    pattern = { "*.sbt", "*.sc" },
    command = "setfiletype scala",
})
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    group = filetypes,
    pattern = "*.hy",
    command = "setfiletype clojure",
})

local folding = vim.api.nvim_create_augroup("folding", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = folding,
    pattern = "vim",
    command = "setlocal foldmethod=marker",
})
vim.api.nvim_create_autocmd("FileType", {
    group = folding,
    pattern = "markdown",
    callback = function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldlevel = 1
        vim.opt_local.foldexpr = "v:lua.markdown_fold_expr(v:lnum)"
        vim.opt_local.foldtext = "v:lua.markdown_fold_text()"
    end,
})

_G.markdown_fold_expr = markdown_fold_expr
_G.markdown_fold_text = markdown_fold_text

local python = vim.api.nvim_create_augroup("python", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = python,
    pattern = "python",
    callback = function(event)
        vim.keymap.set("n", "<F5>", function()
            vim.cmd("!python " .. vim.fn.shellescape(vim.api.nvim_buf_get_name(event.buf)))
        end, { buffer = event.buf, desc = "Run current Python file" })
    end,
})

local javascript = vim.api.nvim_create_augroup("javascript", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = javascript,
    pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
        vim.opt_local.expandtab = true
    end,
})
