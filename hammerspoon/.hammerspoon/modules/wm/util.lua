--- Small pure helpers shared across the window manager.

local M = {}

--- Wrap `index + step` around a collection of `count` elements (1-based).
function M.circular_index(count, index, step)
    return ((index - 1 + step) % count) + 1
end

--- The window's application name, or nil when unavailable.
function M.app_name(window)
    local ok, name = pcall(function()
        return window:application():name()
    end)
    if ok and name then
        return name
    end
    return nil
end

--- The window's numeric id, or nil when unavailable.
function M.window_id(window)
    local ok, id = pcall(function()
        return window:id()
    end)
    if ok and id then
        return id
    end
    return nil
end

--- Stable state key for a window.
--
-- Falls back to the raw window id when the application name is missing, and
-- returns nil when neither lookup succeeds so callers can skip state
-- tracking entirely (rather than colliding on a shared fallback key).
function M.window_key(window)
    local app = M.app_name(window)
    local id = M.window_id(window)
    if app == nil and id == nil then
        return nil
    end
    return string.format("%s_%d", app or "app", id or 0)
end

--- Whether the window manager should handle this window.
--
-- Standard, maximizable windows only; excludes popups, modal dialogs, and
-- floating windows.
--
-- http://www.hammerspoon.org/docs/hs.window.html#isStandard
function M.is_manageable(window)
    if not window or type(window) ~= "userdata" then
        return false
    end
    local ok, manageable = pcall(function()
        return window:isStandard() and window:isMaximizable()
    end)
    return ok and manageable == true
end

--- Build a lookup set from a list of strings.
function M.build_set(list)
    local set = {}
    for _, item in ipairs(list or {}) do
        set[item] = true
    end
    return set
end

return M
