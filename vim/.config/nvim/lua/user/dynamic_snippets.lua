local M = {}

local function completion_item(label, body, documentation)
    return {
        label = label,
        kind = require("blink.cmp.types").CompletionItemKind.Snippet,
        insertText = body,
        insertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet,
        documentation = {
            kind = "markdown",
            value = documentation,
        },
    }
end

local function random_string(length)
    local characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for index = 1, length do
        local position = math.random(#characters)
        result[index] = characters:sub(position, position)
    end
    return table.concat(result)
end

local function week_days(reverse)
    local now = os.date("*t")
    local monday_offset = (now.wday + 5) % 7
    local monday =
        os.time({ year = now.year, month = now.month, day = now.day - monday_offset, hour = 12 })
    local days = {}
    for index = 0, 4 do
        table.insert(days, os.date("## %a, %Y-%m-%d", monday + (index * 24 * 60 * 60)))
    end
    if reverse then
        return table.concat(vim.fn.reverse(days), "\n")
    end
    return table.concat(days, "\n")
end

local function box(width)
    local comment = vim.trim((vim.bo.commentstring:match("^(.-)%%s") or "#"))
    local border = string.rep(comment:sub(1, 1), width)
    local placeholder = "placeholder"
    local padding = math.max(0, math.floor((width - (2 * #comment) - #placeholder) / 2))
    local content = comment
        .. string.rep(" ", padding)
        .. "${1:"
        .. placeholder
        .. "}"
        .. string.rep(" ", padding)
        .. comment
    return table.concat({ border, content, border }, "\n")
end

function M.new()
    return setmetatable({}, { __index = M })
end

function M:get_completions(context, callback)
    local items = {
        completion_item("rand", random_string(16), "Random 16-character string"),
        completion_item("uuid", "${UUID}", "UUIDv4"),
        completion_item("box", box(24), "24-character comment box"),
        completion_item(
            "bbox",
            box(vim.bo.textwidth > 0 and vim.bo.textwidth or 80),
            "Comment box using textwidth"
        ),
    }

    if vim.bo[context.bufnr].filetype == "vimwiki" then
        table.insert(items, completion_item("days", week_days(false), "Current week's weekdays"))
        table.insert(
            items,
            completion_item("rdays", week_days(true), "Current week's weekdays in reverse")
        )
    end

    callback({
        items = items,
        is_incomplete_backward = false,
        is_incomplete_forward = false,
    })
    return function() end
end

return M
