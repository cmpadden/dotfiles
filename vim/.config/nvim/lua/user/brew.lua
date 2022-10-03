-- The following is extracted and modified from plenary.vnim by
-- TJ Devries. It is not a stable API, and is expected to change
--
local function apply_defaults(original, defaults)
    if original == nil then
        original = {}
    end

    original = vim.deepcopy(original)

    for k, v in pairs(defaults) do
        if original[k] == nil then
            original[k] = v
        end
    end

    return original
end

local win_float = {}

win_float.default_options = {
    winblend = 15,
    percentage = 0.9,
}

function win_float.default_opts(options)
    options = apply_defaults(options, win_float.default_options)

    local width = math.floor(vim.o.columns * options.percentage)
    local height = math.floor(vim.o.lines * options.percentage)

    local top = math.floor(((vim.o.lines - height) / 2) - 1)
    local left = math.floor((vim.o.columns - width) / 2)

    local opts = {
        relative = "editor",
        row = top,
        col = left,
        width = width,
        height = height,
        style = "minimal",
        border = {
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
        },
    }

    return opts
end

--- Create window that takes up certain percentags of the current screen.
---
--- Works regardless of current buffers, tabs, splits, etc.
--@param col_range number | Table:
--                  If number, then center the window taking up this percentage of the screen.
--                  If table, first index should be start, second_index should be end
--@param row_range number | Table:
--                  If number, then center the window taking up this percentage of the screen.
--                  If table, first index should be start, second_index should be end
function win_float.percentage_range_window(col_range, row_range, options)
    options = apply_defaults(options, win_float.default_options)

    local win_opts = win_float.default_opts(options)
    win_opts.relative = "editor"

    local height_percentage, row_start_percentage
    if type(row_range) == "number" then
        assert(row_range <= 1)
        assert(row_range > 0)
        height_percentage = row_range
        row_start_percentage = (1 - height_percentage) / 2
    elseif type(row_range) == "table" then
        height_percentage = row_range[2] - row_range[1]
        row_start_percentage = row_range[1]
    else
        error(string.format("Invalid type for 'row_range': %p", row_range))
    end

    win_opts.height = math.ceil(vim.o.lines * height_percentage)
    win_opts.row = math.ceil(vim.o.lines * row_start_percentage)

    local width_percentage, col_start_percentage
    if type(col_range) == "number" then
        assert(col_range <= 1)
        assert(col_range > 0)
        width_percentage = col_range
        col_start_percentage = (1 - width_percentage) / 2
    elseif type(col_range) == "table" then
        width_percentage = col_range[2] - col_range[1]
        col_start_percentage = col_range[1]
    else
        error(string.format("Invalid type for 'col_range': %p", col_range))
    end

    win_opts.col = math.floor(vim.o.columns * col_start_percentage)
    win_opts.width = math.floor(vim.o.columns * width_percentage)

    local bufnr = options.bufnr or vim.api.nvim_create_buf(false, true)
    local win_id = vim.api.nvim_open_win(bufnr, true, win_opts)
    vim.api.nvim_win_set_buf(win_id, bufnr)

    vim.cmd("setlocal nocursorcolumn ts=2 sw=2")

    return {
        bufnr = bufnr,
        win_id = win_id,
    }
end

-- return win_float
local windows = win_float

--------------------------------------------------------------------------------

local api = vim.api

-- adapted from nvim-lspconfig's :LspInfo window
local make_window = function(height_percentage, width_percentage)
    local row_start_percentage = (1 - height_percentage) / 2
    local col_start_percentage = (1 - width_percentage) / 2

    local row = math.ceil(vim.o.lines * row_start_percentage)
    local col = math.ceil(vim.o.columns * col_start_percentage)
    local width = math.floor(vim.o.columns * width_percentage)
    local height = math.ceil(vim.o.lines * height_percentage)

    local opts = {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        style = "minimal",
        border = {
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
            { " ", "NormalFloat" },
        },
    }

    local bufnr = api.nvim_create_buf(false, true)
    local win_id = api.nvim_open_win(bufnr, true, opts)
    api.nvim_win_set_buf(win_id, bufnr)

    vim.cmd("setlocal nocursorcolumn ts=2 sw=2")

    return bufnr, win_id
end

local win_bufnr, win_id = make_window(0.8, 0.7)


-- local result = vim.fn.systemlist('date')


api.nvim_buf_set_lines(win_bufnr, 0, -1, true, {})
api.nvim_buf_set_option(win_bufnr, "buftype", "nofile")
api.nvim_buf_set_option(win_bufnr, "filetype", "null-ls-info")
api.nvim_buf_set_option(win_bufnr, "modifiable", true)

api.nvim_buf_set_keymap(win_bufnr, "n", "<Esc>", "<cmd>bd<CR>", { noremap = true })

local timer = vim.loop.new_timer()
timer:start(0, 1000, vim.schedule_wrap(function()
    local result = vim.fn.systemlist('date')
    api.nvim_buf_set_lines(win_bufnr, 0, -1, true, result)
end))

timer:stop()

--------------------------------------------------------------------------------

-- local win_info = windows.percentage_range_window(0.8, 0.7)
-- local bufnr, win_id = win_info.bufnr, win_info.win_id

-- local buf_lines = {}

-- local header = {
--   '',
--   'Language client log: ',
--   'Detected filetype:   ',
-- }
-- vim.list_extend(buf_lines, header)

-- vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, buf_lines)
-- vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
-- vim.api.nvim_buf_set_option(bufnr, 'filetype', 'brewinfo')

-- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<esc>', '<cmd>bd<CR>', { noremap = true })
-- vim.api.nvim_command(
--   string.format('autocmd BufHidden,BufLeave <buffer> ++once lua pcall(vim.api.nvim_win_close, %d, true)', win_id)
-- )
