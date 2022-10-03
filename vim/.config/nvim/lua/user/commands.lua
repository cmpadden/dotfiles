vim.api.nvim_create_user_command(
  'HexEncode',
  ':%!xxd',
  {desc = 'Hex encode current file with xxd'}
)

vim.api.nvim_create_user_command(
  'HexDecode',
  ':%!xxd -r',
  {desc = 'Hex dump current file with xxd'}
)

vim.api.nvim_create_user_command(
  'W',
  'w',
  {bang = true, desc = 'For all those times you accidentally type :W'}
)

vim.api.nvim_create_user_command(
  'Ag',
  "call fzf#vim#ag(<q-args>, {'options': '--delimiter : --nth 4..'}, <bang>0)",
  {bang = true, desc = 'Override `Ag` command to exclude filenames in search'}
)

vim.api.nvim_create_user_command(
  'ToggleSignColumn',
  function(input)
    if vim.o.signcolumn == 'yes' then
        vim.o.signcolumn = 'no'
    else
        vim.o.signcolumn = 'yes'
    end
  end,
  {desc = 'Toggle the `&signcolumn`'}
)
