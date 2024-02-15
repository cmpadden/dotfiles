--[[ Chatblade.nvim

BACKGROUND

    The `chatblade.nvim` plugin provides a barebones wrapper around the `chatblade`
    command line utility. It's easy to call out to `chatblade` without the need for
    YAP (yet-another-plugin), however, this plugin aims to add a few quality of life
    improvements, and possible configurations over that. If you would prefer to _not_
    use a plugin, you may find the following binding helpful:

        vim.keymap.set("v", "<leader>c", ':!chatblade -e -r<CR>')

PREREQUISITES

    - Install the `chatblade` CLI
    - Set the `OPENAI_API_KEY` environment variable

FEATURE TRACKING

    - [ ] explore `line1`, `line2` and `rows` available in `params` in `nvim_create_user_command`
    - [ ] handle creation of prompt files
    - [x] handle sessions
    - [ ] include filetype information in the prompt
    - [ ] Default to randomly generated session
]]
--

local M = {
    active_session = nil,
}

-- Lua 5.1 backwards compatibility
-- https://github.com/hrsh7th/nvim-cmp/issues/1017#issuecomment-1141440976
unpack = unpack or table.unpack

----------------------------------------------------------------------------------------
--                                       Utils                                        --
----------------------------------------------------------------------------------------

-- Gets row and column indexes for a visual selection.
-- @return array of start and end indexes for selected lines
local function get_visual_selection_indexes()
    local srow, scol = unpack(vim.fn.getpos("'<"), 2)
    local erow, ecol = unpack(vim.fn.getpos("'>"), 2)
    return srow, scol, erow, ecol
end

-- Gets text in current buffer given selection indexes.
-- @param srow index of visual start row
-- @param scol index of visual start column
-- @param erow index of visual end row
-- @param ecol index of visual end column
local function get_visual_selection(srow, scol, erow, ecol)
    local lines = vim.api.nvim_buf_get_lines(0, srow - 1, erow, false)
    if #lines == 0 then
        return nil
    end
    lines[1] = string.sub(lines[1], scol)
    lines[#lines] = string.sub(lines[#lines], 1, ecol)
    return lines
end

-- Puts array of lines below specified `line_number`.
-- @param line_number line to place text below
-- @param lines array of strings to place into buffer
local function put_lines_below_line(line_number, lines)
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

function M.start_session(session_name)
    M.active_session = session_name
    print(string.format("Activated session %s!", session_name))
end

function M.stop_session(session_name)
    M.active_session = nil
    print(string.format("Deactivated session %s!", session_name))
end

function M.delete_session(session_name)
    M.active_session = nil
    local stdout = vim.fn.system({ "chatblade", "--session-delete", session_name })
    print(stdout)
end

function M.run(user_config)
    print('Awaiting response...')
    local config = M.default_config
    if user_config then
        config = vim.tbl_deep_extend("force", user_config, M.default_config)
    end

    local srow, scol, erow, ecol = get_visual_selection_indexes()

    local selected_lines = get_visual_selection(srow, scol, erow, ecol)
    if not selected_lines then
        return
    end

    local command = { "chatblade" }

    if M.active_session then
        table.insert(command, "--session")
        table.insert(command, M.active_session)
        print(string.format("using session %s", M.active_session))
    end

    if config.raw then
        table.insert(command, "--raw")
    end

    if config.extract then
        table.insert(command, "--extract")
    end

    -- NOTE: we currently do not send the prompt if a session is active. This is because
    -- an error is thrown if a prompt is used _after_ a session has already been called
    -- with a given prompt. We need to determine how to only pass the prompt on the
    -- first call to a session, even if that session was created outside of the context
    -- of Neovim.

    if config.prompt and not M.active_session then
        table.insert(command, "--prompt-file")
        table.insert(command, config.prompt)
    end

    local stdout = vim.fn.systemlist(command, selected_lines)

    put_lines_below_line(erow, stdout)
end

return M
