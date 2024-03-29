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

-- softwrap markdown files; we like long lines
--
-- References:
-- - https://stackoverflow.com/a/26015800
-- - https://stackoverflow.com/a/26284471
vim.cmd([[
  augroup markdownWrap
      autocmd!
      autocmd FileType markdown set wrap linebreak showbreak=>>>

  augroup END
]])
