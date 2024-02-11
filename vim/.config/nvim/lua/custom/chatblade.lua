--[[ Chatblade.nvim

REQUIREMENTS

    - Populate `OPENAI_API_KEY` environment variable

TRACKING

    - explore `line1`, `line2` and `rows` available in `params` in `nvim_create_user_command`
    - handle creation of prompt files
    - handle sessions
    - include filetype information in the prompt
]]
--

local M = {}

-- Lua 5.1 backwards compatibility
-- https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141440976
unpack = unpack or table.unpack

----------------------------------------------------------------------------------------
--                                       Utils                                        --
----------------------------------------------------------------------------------------

local function get_visual_selection_indexes()
    local srow, scol = unpack(vim.fn.getpos("'<"), 2)
    local erow, ecol = unpack(vim.fn.getpos("'>"), 2)
    return srow, scol, erow, ecol
end

local function get_visual_selection(srow, scol, erow, ecol)
    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
    if #lines == 0 then
        return nil
    end
    lines[1] = string.sub(lines[1], scol)
    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    return lines
end

local function put_lines_below_line_number(line_number, lines)
    -- local current_line = unpack(vim.api.nvim_win_get_cursor(0), 1)
    vim.api.nvim_buf_set_lines(0, line_number, line_number, true, lines)
end

----------------------------------------------------------------------------------------
--                                     Entrypoint                                     --
----------------------------------------------------------------------------------------

-- stylua: ignore
M.default_config = {
    prompt  = "programmer", -- custom prompts: nil, 'programmer', 'explain'
    raw     = true,         -- print session as pure text
    extract = true,         -- extract content from response if possible (either json or code)
    only    = true,         -- only display the response, not the query
}

function M.run(user_config)
    local config = M.default_config
    if user_config then
        config = vim.tbl_deep_extend("force", user_config, M.default_config)
    end

    local srow, scol, erow, ecol = get_visual_selection_indexes()

    local selected_lines = get_visual_selection(srow, scol, erow, ecol)
    if not selected_lines then
        return
    end

    local command = { "chatblade", "--raw" }

    if config.extract then
        table.insert(command, "--extract")
    end

    if config.prompt then
        table.insert(command, "--prompt-file")
        table.insert(command, config.prompt)
    end

    local stdout = vim.fn.systemlist(command, selected_lines)

    put_lines_below_line_number(erow, stdout)
end

return M
