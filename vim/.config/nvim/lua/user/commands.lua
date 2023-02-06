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

vim.api.nvim_create_user_command(
  'Notes',
  ":e ~/notes.md.asc",
  {bang = false, desc = 'Edit notes.md'}
)
