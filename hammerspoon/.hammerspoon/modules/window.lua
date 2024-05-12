--- Window Management

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


-- stylua: ignore start
obj.layouts = {
    [1] = {
        Calendar            = hs.layout.maximized,
        Chromium            = hs.layout.maximized,
        Discord             = hs.layout.maximized,
        Firefox             = hs.layout.maximized,
        Gather              = PIP_BOTTOM_RIGHT,
        Stickies            = PIP_TOP_RIGHT,
        LibreWolf           = hs.layout.maximized,
        Mail                = hs.layout.maximized,
        Messages            = hs.layout.maximized,
        Notes               = hs.layout.maximized,
        Notion              = hs.layout.maximized,
        Safari              = hs.layout.maximized,
        Slack               = hs.layout.maximized,
        Spotify             = hs.layout.maximized,
        ["Bitwig Studio"]   = hs.layout.maximized,
        ["Google Chrome"]   = hs.layout.maximized,
        ["Logic Pro"]       = hs.layout.maximized,
        ["Notion Calendar"] = hs.layout.maximized,
        ["zoom.us"]         = hs.layout.maximized,
        kitty               = hs.layout.maximized,
        Linear              = hs.layout.maximized,
    },
    [2] = {
        Calendar            = RECT_RIGHT,
        Chromium            = RECT_RIGHT,
        Discord             = RECT_RIGHT,
        Firefox             = RECT_RIGHT,
        Gather              = PIP_BOTTOM_RIGHT,
        Stickies            = PIP_TOP_RIGHT,
        LibreWolf           = RECT_RIGHT,
        Linear              = RECT_LEFT,
        Mail                = RECT_RIGHT,
        Messages            = RECT_RIGHT,
        Notes               = RECT_RIGHT,
        Notion              = RECT_RIGHT,
        Safari              = RECT_RIGHT,
        Slack               = RECT_RIGHT,
        Spotify             = RECT_RIGHT,
        ["Bitwig Studio"]   = RECT_LEFT,
        ["Google Chrome"]   = RECT_RIGHT,
        ["Logic Pro"]       = RECT_RIGHT,
        ["Notion Calendar"] = RECT_LEFT,
        ["zoom.us"]         = RECT_RIGHT,
        kitty               = RECT_LEFT,
    },
    [3] = {
        Calendar            = RECT_CENTER,
        Chromium            = RECT_CENTER,
        Discord             = RECT_CENTER,
        Firefox             = RECT_CENTER,
        Gather              = PIP_BOTTOM_RIGHT,
        Stickies            = PIP_TOP_RIGHT,
        LibreWolf           = RECT_CENTER,
        Linear              = RECT_CENTER,
        Mail                = RECT_CENTER,
        Messages            = RECT_CENTER,
        Notes               = RECT_CENTER,
        Notion              = RECT_CENTER,
        Safari              = RECT_CENTER,
        Slack               = RECT_CENTER,
        Spotify             = RECT_CENTER,
        ["Bitwig Studio"]   = RECT_CENTER,
        ["Google Chrome"]   = RECT_CENTER,
        ["Logic Pro"]       = RECT_CENTER,
        ["Notion Calendar"] = RECT_CENTER,
        ["zoom.us"]         = RECT_CENTER,
        kitty               = RECT_CENTER,
    },
    [4] = {
        Calendar            = RECT_SKINNY,
        Chromium            = RECT_SKINNY,
        Discord             = RECT_SKINNY,
        Firefox             = RECT_SKINNY,
        LibreWolf           = RECT_SKINNY,
        Linear              = RECT_SKINNY,
        Mail                = RECT_SKINNY,
        Messages            = RECT_SKINNY,
        Notes               = RECT_SKINNY,
        Notion              = RECT_SKINNY,
        Safari              = RECT_SKINNY,
        Slack               = RECT_SKINNY,
        Spotify             = RECT_SKINNY,
        ["Bitwig Studio"]   = RECT_SKINNY,
        ["Google Chrome"]   = RECT_SKINNY,
        ["Logic Pro"]       = RECT_SKINNY,
        ["Notion Calendar"] = RECT_SKINNY,
        ["zoom.us"]         = RECT_SKINNY,
        kitty               = RECT_SKINNY,
    }
}
-- stylua: ignore end

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

function obj:set_layout(layout)
    self.layout = layout
    local active_layout = self.layouts[layout]
    local active_windows = self.window_filter_all:getWindows()

    for _, window in ipairs(active_windows) do
        local app_name = window:application():name()
        local target_geometry = active_layout[app_name]
        if target_geometry then
            _move_to_unit_with_retries(target_geometry, window)
        end
    end
end

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
}

--- State tracking layout > application > window geometry
local state = {
    -- [1] = { application_name_1 = 1, application_name_2 = 1 }
    -- [2] = { application_name_1 = 1, application_name_2 = 3 }
}

--- Move window to cached geometry or default to geometry at index 1.
function obj:set_layout_new(layout)
    self.layout = layout
    local active_layout = layouts[layout]
    local active_windows = self.window_filter_all:getWindows()

    for _, window in ipairs(active_windows) do
        local app_name = window:application():name()
        local target_geometry = active_layout[app_name]
        if target_geometry then
            _move_to_unit_with_retries(target_geometry, window)
        end
    end
end

function obj:init()
    hs.window.animationDuration = 0
    hs.window.setFrameCorrectness = true
    self.layout = 1

    -- Automatic layout application to new/focused windows.
    self.window_filter_all = hs.window.filter.new()

    -- Consider usage of `windowCreated` and `windowFocused` for ideal resizing trigger
    self.window_filter_all:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        local target_geometry = self.layouts[obj.layout][app_name]
        _move_to_unit_with_retries(target_geometry, window)
    end)

    -- bind layouts to corresponding 1, 2, ..., n
    for key, _ in pairs(self.layouts) do
        hs.hotkey.bind({ "cmd", "ctrl" }, tostring(key), function()
            obj:set_layout_new(key)
        end)
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
        hs.alert("!")
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
            hs.alert(#table + index + step)
            return #table + index + step
        else
            return index + step
        end
    end

    local function move_focused_window_next_geometry(direction)
        local focused_window = hs.window.focusedWindow()
        local focused_application_name = focused_window:application():name()
        hs.alert(focused_application_name)

        local current_index = get_application_geometry_index(self.layout, focused_application_name)
        hs.alert(current_index)
        local next_index = next_index_circular(layouts[self.layout], current_index, direction)
        hs.alert(next_index)
        hs.alert(#layouts[self.layout])
        set_application_geometry_index(self.layout, focused_application_name, next_index)

        local target_geometry = layouts[self.layout][next_index]
        focused_window:moveToUnit(target_geometry)
    end

    local function hs_alert_window_state()
        if state[self.layout] == nil then
            hs.alert(string.format("No state for layout: %s", self.layout))
            return
        end
        local lines = {}
        lines[#lines + 1] = string.format("Active Layout: %s", self.layout)
        lines[#lines + 1] = string.rep("-", 80)
        for application, geometry_index in pairs(state[self.layout]) do
            lines[#lines + 1] = string.format("%-79s %s", application, geometry_index)
        end
        hs.alert(table.concat(lines, "\n"))
    end

    hs.hotkey.bind({ "cmd", "shift" }, "l", function()
        move_focused_window_next_geometry(1)
    end)
    hs.hotkey.bind({ "cmd", "shift" }, "h", function()
        move_focused_window_next_geometry(-1)
    end)
    hs.hotkey.bind({ "cmd", "shift" }, "/", function()
        hs_alert_window_state()
    end)
end

return obj
