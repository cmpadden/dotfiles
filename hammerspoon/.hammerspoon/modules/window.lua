--- Window Management
--
-- Task list:
-- - [ ] Multi-monitor support
-- - [ ] Differing geometries for multiple windows in the same application

-- New implementation:
-- * Cycle active window between geometries in a given layout (directional cycle)
-- * Create layout definitions that is table of geometries
-- * Track assigned window geometries
-- * Default created window to geometry 1 of layout
-- * Export to WindowManager.Spoon
-- * Parameterize disabling of animations

local obj = {
    name = "Window Management",
    version = "1.0.0",
    config = {
        default_layout = 3,
        split_padding = 0.08,
        padding = 0.02,
        window_width_centered = 0.65,
        window_width_skinny = 0.35,
        pip_height = 0.35,
        pip_width = 0.142,
        state_file_path = os.getenv("HOME") .. "/.hammerspoon/_wm.spoon.state.json",
    },
}

-- Encapsulate access of configuration values for improved ability to refactor, and readability.
local function get_config(key)
    return obj.config[key]
end

local RECT_CENTER = hs.geometry({
    h = (1 - (2 * get_config("padding"))),
    w = get_config("window_width_centered"),
    x = ((1 - get_config("window_width_centered")) / 2),
    y = get_config("padding"),
})

local RECT_LEFT = hs.geometry({
    h = (1 - (2 * get_config("padding"))),
    w = (0.5 - (get_config("split_padding") + 0.005)),
    x = get_config("split_padding"),
    y = get_config("padding"),
})

local RECT_RIGHT = hs.geometry({
    h = (1 - (2 * get_config("padding"))),
    w = (0.5 - get_config("split_padding") - 0.005),
    x = (0.5 + 0.005),
    y = get_config("padding"),
})

local RECT_SKINNY = hs.geometry({
    h = (1 - (2 * get_config("padding"))),
    w = get_config("window_width_skinny"),
    x = ((1 - get_config("window_width_skinny")) / 2),
    y = get_config("padding"),
})

local PIP_BOTTOM_RIGHT = hs.geometry({
    h = get_config("pip_height"),
    w = get_config("pip_width"),
    x = (1 - 0.162),
    y = ((1 - get_config("pip_height")) - get_config("padding")),
})

local PIP_TOP_RIGHT = hs.geometry({
    h = get_config("pip_height"),
    w = get_config("pip_width"),
    x = get_config("padding"),
    y = get_config("padding"),
})

local state = {
    -- [1] = { application_name_1 = 1, application_name_2 = 1 }
    -- [2] = { application_name_1 = 1, application_name_2 = 3 }
}

local layouts = {
    [1] = {
        RECT_LEFT,
        RECT_RIGHT,
    },
    [2] = {
        RECT_LEFT,
        RECT_RIGHT,
        PIP_BOTTOM_RIGHT,
    },
    [3] = {
        RECT_CENTER,
        PIP_BOTTOM_RIGHT,
    },
    [4] = {
        RECT_SKINNY,
        PIP_TOP_RIGHT,
    },
}

--- Converts a unitrect (relative coordinates) to a rect (absolute coordinates) based on the main screen's frame.
-- --- @param unit_rect hs.geometry A unitrect representing relative coordinates.
-- --- @return hs.geometry A rect representing absolute coordinates.
local function _unit_rect_to_rect(unit_rect)
    local screen_frame = hs.screen.mainScreen():frame()
    return hs.geometry.rect(
        screen_frame.x + (unit_rect.x * screen_frame.w),
        screen_frame.y + (unit_rect.y * screen_frame.h),
        unit_rect.w * screen_frame.w,
        unit_rect.h * screen_frame.h
    )
end

-- Temporary workaround: move windows until we confirm that they are at the frame that
-- we expect. Have a retry of 3 to prevent any unwanted infinite loops. For more
-- information reference the open github issue:
--
-- https://github.com/Hammerspoon/hammerspoon/issues/3624
local function _move_to_unit_with_retries(geometry, window)
    window:moveToUnit(geometry)
    local retries = 3
    hs.timer.doUntil(function()
        return retries == 0 or window:frame():equals(_unit_rect_to_rect(geometry):floor())
    end, function()
        window:moveToUnit(geometry)
        retries = retries - 1
    end, 0.25)
end

local function get_application_geometry_index(layout, application_name)
    if state[layout] == nil then
        state[layout] = {}
        state[layout][application_name] = 1
        return 1
    end

    if state[layout][application_name] == nil then
        state[layout][application_name] = 1
        return 1
    end

    return state[layout][application_name]
end

local function set_application_geometry_index(layout, application_name, index)
    if state[layout] == nil then
        state[layout] = {}
        state[layout][application_name] = index
        return
    end
    state[layout][application_name] = index
end

--- Traverse `table` by `step` wrapping around to the beginning and end of the table.
--
-- If Lua arrays had a 0-based index, then this would be simple using the modulus operator,
-- however, instead we have to do this hacky workaround. See another user with the same
-- bewilderment: https://devforum.roblox.com/t/wrapping-index-in-an-array/1476197/2
--
---@param table table table to traverse
---@param index integer current index of table
---@param step integer positive or negative value to iterate over table
local function next_index_circular(table, index, step)
    if #table == 1 then
        return 1
    end
    if step > 0 and index + step > #table then
        return index + step - #table
    elseif step < 0 and index + step <= 0 then
        return #table + index + step
    else
        return index + step
    end
end

function obj:move_focused_window_next_geometry(direction)
    local focused_window = hs.window.focusedWindow()
    local focused_application_name = focused_window:application():name()

    local current_index = get_application_geometry_index(self.layout, focused_application_name)
    local next_index = next_index_circular(layouts[self.layout], current_index, direction)
    set_application_geometry_index(self.layout, focused_application_name, next_index)

    local target_geometry = layouts[self.layout][next_index]
    focused_window:moveToUnit(target_geometry)
end

function obj:set_layout_new(layout)
    self.layout = layout
    local active_layout = layouts[layout]

    local active_windows = self.window_filter_all:getWindows()
    for _, window in ipairs(active_windows) do
        local app_name = window:application():name()
        local ix = get_application_geometry_index(layout, app_name)
        local target_geometry = active_layout[ix]
        _move_to_unit_with_retries(target_geometry, window)
    end
end

function obj:save_state()
    local path = get_config("state_file_path")
    hs.json.write(state, path, true, true)
    hs.alert(string.format("wm.spoon state written to file: %s", path))
end

function obj:load_state()
    local path = get_config("state_file_path")
    obj.state = hs.json.read(path)
    hs.alert(string.format("wm.spoon state loaded from file: %s", path))
end

function obj:init()
    hs.window.animationDuration = 0
    hs.window.setFrameCorrectness = true
    self.layout = 1

    -- Automatic layout application to new/focused windows.
    self.window_filter_all = hs.window.filter.new()

    -- Consider usage of `windowCreated` and `windowFocused` for ideal resizing trigger
    -- TODO refactor this so that movement and getting layout is shared
    self.window_filter_all:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        local ix = get_application_geometry_index(self.layout, app_name)
        local target_geometry = layouts[self.layout][ix]
        _move_to_unit_with_retries(target_geometry, window)
    end)

    -- bind layouts to corresponding 1, 2, ..., n
    for key, _ in pairs(layouts) do
        hs.hotkey.bind({ "cmd", "ctrl" }, tostring(key), function()
            obj:set_layout_new(key)
            -- obj:set_layout(key)
        end)
    end

    --- Display cached state window geometries for active layout
    local function hs_alert_window_state()
        if state[self.layout] == nil then
            hs.alert(string.format("No state for layout: %s", self.layout))
            return
        end
        local lines = {}
        lines[#lines + 1] = string.format("Active Layout: %s", self.layout)
        lines[#lines + 1] = string.rep("-", 80)
        for application, geometry_index in pairs(state[self.layout]) do
            lines[#lines + 1] = string.format("%-40s %40s", application, geometry_index)
        end
        hs.alert(table.concat(lines, "\n"))
    end

    hs.hotkey.bind({ "cmd", "shift" }, "l", function()
        self:move_focused_window_next_geometry(1)
    end)
    hs.hotkey.bind({ "cmd", "shift" }, "h", function()
        self:move_focused_window_next_geometry(-1)
    end)
    hs.hotkey.bind({ "cmd", "shift" }, "/", function()
        hs_alert_window_state()
    end)
    hs.hotkey.bind({ "cmd", "control" }, "-", function()
        self:save_state()
    end)
    hs.hotkey.bind({ "cmd", "control" }, "=", function()
        self:load_state()
    end)
end

return obj
