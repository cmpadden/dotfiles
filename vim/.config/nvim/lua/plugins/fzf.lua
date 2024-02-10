return {
    {
        "junegunn/fzf",
        dir = "~/.fzf",
        build = "./install --bin",
    },

    {
        "ibhagwan/fzf-lua",
        init = function()
            -- fzf.lua
            vim.keymap.set("n", "<c-f>f", "<cmd>lua require('fzf-lua').files()<CR>")
            vim.keymap.set("n", "<c-f>n", "<cmd>lua require('fzf-lua').git_files()<CR>")
            vim.keymap.set("n", "<c-f>l", "<cmd>lua require('fzf-lua').blines()<CR>")
            -- vim.keymap.set("n", "<c-f>g", "<cmd>lua require('fzf-lua').live_grep()<CR>")
            vim.keymap.set(
                "n",
                "<c-f>g",
                "<cmd>lua require('fzf-lua').live_grep_native()<CR>"
            )
            vim.keymap.set("n", "<c-f>h", "<cmd>lua require('fzf-lua').help_tags()<CR>")
            vim.keymap.set(
                "n",
                "<c-f>c",
                "<cmd>lua require('fzf-lua').git_bcommits()<CR>"
            )
            vim.keymap.set("n", "<c-f>b", "<cmd>lua require('fzf-lua').buffers()<CR>")
            vim.keymap.set(
                "n",
                "<c-f>d",
                "<cmd>lua require('fzf-lua').diagnostics_document()<CR>"
            )
        end,
        opts = {
            winopts = {
                height = 0.50,
                width = 0.85,
            },
        },
    },
}
