local M = {}

function M.setup()
    -- https://github.com/jpalardy/vim-slime
    vim.g.slime_target = "tmux"
    vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
    vim.g.slime_dont_ask_default = 1
    vim.g.slime_bracketed_paste = 1

    -- https://github.com/junegunn/goyo.vim
    vim.g.goyo_height = "100%"
    vim.g.goyo_width = "88"
    vim.keymap.set("n", "<localleader>G", ":Goyo<CR>")
    vim.cmd([[
        function! s:goyo_enter()
          :Gitsigns toggle_signs
          if exists('$TMUX')
            silent !tmux set status off
          endif
        endfunction

        function! s:goyo_leave()
          :Gitsigns toggle_signs
          if exists('$TMUX')
            silent !tmux set status on
          endif
        endfunction

        autocmd! User GoyoEnter nested call <SID>goyo_enter()
        autocmd! User GoyoLeave nested call <SID>goyo_leave()
    ]])

    -- https://github.com/junegunn/vim-easy-align
    vim.keymap.set("x", "ga", "<Plug>(EasyAlign)")
    vim.keymap.set("n", "ga", "<Plug>(EasyAlign)")

    -- https://github.com/ellisonleao/carbon-now.nvim
    require("carbon-now").setup({
        open_cmd = "open",
        options = {
            drop_shadow_blur = "68px",
            drop_shadow = false,
            drop_shadow_offset_y = "20px",
            font_family = "Hack",
            font_size = "18px",
            line_height = "133%",
            line_numbers = true,
            theme = "shades-of-purple",
            titlebar = "",
            watermark = false,
            width = "680",
            window_theme = "round",
            bg = "black",
        },
    })
    vim.keymap.set("v", "<leader>cn", ":CarbonNow<CR>", { silent = true })
end

return M
