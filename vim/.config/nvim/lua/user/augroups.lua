------------------------------------------------------------------------------------------
--                                    Auto Commands                                     --
------------------------------------------------------------------------------------------

-- after opening `help` files, move them to the right
-- vim.cmd([[
--   augroup helpFileType
--     autocmd!
--     autocmd FileType help wincmd L
--   augroup END
-- ]])

-- enable spell checking for certain file types
vim.cmd([[
  augroup spellChecking
    autocmd!
    autocmd FileType vimwiki setlocal spell
    autocmd FileType markdown setlocal spell
  augroup END
]])

-- Help Vim recognize *.sbt and *.sc as Scala files
vim.cmd([[
  augroup scalaFiletypes
    autocmd BufRead,BufNewFile *.sbt,*.sc set filetype=scala
  augroup END
]])

vim.cmd([[
  augroup foldmethod_markers
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
  augroup END
]])

-- vimscript function for markdown folding
vim.cmd([[
  function! MarkdownFoldExpr(lnum)
    let line = getline(a:lnum)
    if line =~ '^###### '
      return '>6'
    elseif line =~ '^##### '
      return '>5'
    elseif line =~ '^#### '
      return '>4'
    elseif line =~ '^### '
      return '>3'
    elseif line =~ '^## '
      return '>2'
    elseif line =~ '^# '
      return '>1'
    else
      return '='
    endif
  endfunction

  function! CustomMarkdownFoldText()
    let line = getline(v:foldstart)
    let line_count = v:foldend - v:foldstart + 1
    return line . ' [' . line_count . ']'
  endfunction
]])

-- Set fold expression and level for markdown files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldlevel = 1
    vim.opt_local.foldexpr = "MarkdownFoldExpr(v:lnum)"
    vim.opt_local.foldtext = "CustomMarkdownFoldText()"
  end,
})

-- run Python code
vim.cmd([[
  augroup pythonMappings
      autocmd!
      autocmd Filetype python nnoremap <buffer> <F5> :exec '!python' shellescape(@%, 1)<cr>
  augroup END
]])

-- Meh, it's close enough...
vim.cmd([[
  augroup hySyntax
      autocmd!
      autocmd BufNewFile,BufRead *.hy set syntax=clojure
  augroup END
]])

-- -- softwrap markdown files; we like long lines
-- --
-- -- References:
-- -- - https://stackoverflow.com/a/26015800
-- -- - https://stackoverflow.com/a/26284471
-- vim.cmd([[
--   augroup markdownWrap
--       autocmd!
--       autocmd FileType markdown set wrap linebreak showbreak=>>>
--
--   augroup END
-- ]])

-- todo: consider `.editorconfig`
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"},
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab = true
  end
})
