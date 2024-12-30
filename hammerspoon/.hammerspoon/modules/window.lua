--- Window Management
--
-- Tracking:
-- - [ ] Multi-monitor support
-- - [ ] Differing geometries for multiple windows in the same application
-- - [ ] Parameterize animation disable

local obj = {
    name = "wm.spoon",
    config = {
        default_layout = 2,
        state_file_path = os.getenv("HOME") .. "/.hammerspoon/_wm.spoon.state.json",
        layouts = {},
        bindings = {
            prefix = { "cmd", "shift" },
            cycle_left = "h",
            cycle_right = "l",
            state_save = "-",
            state_restore = "=",
            state_alert = "/",
        },
    },
    -- Store the most layout index for each application in each layout
    state = {
        -- [1] = { application_name_1 = 1, application_name_2 = 1 }
        -- [2] = { application_name_1 = 1, application_name_2 = 3 }
    },
}

local split_padding = 0.08
local padding = 0.02
local window_width_centered = 0.65
local window_width_skinny = 0.35
local pip_height = 0.35
local pip_width = 0.142

--- Predefined geometries
obj.builtins = {
    full = hs.geometry({
        h = 1,
        w = 1,
        x = 0,
        y = 0,
    }),

    padded_center = hs.geometry({
        h = (1 - (2 * padding)),
        w = window_width_centered,
        x = ((1 - window_width_centered) / 2),
        y = padding,
    }),

    padded_left = hs.geometry({
        h = (1 - (2 * padding)),
        w = (0.5 - (split_padding + 0.005)),
        x = split_padding,
        y = padding,
    }),

    padded_right = hs.geometry({
        h = (1 - (2 * padding)),
        w = (0.5 - split_padding - 0.005),
        x = (0.5 + 0.005),
        y = padding,
    }),

    skinny = hs.geometry({
        h = (1 - (2 * padding)),
        w = window_width_skinny,
        x = ((1 - window_width_skinny) / 2),
        y = padding,
    }),

    pip_bottom_right = hs.geometry({
        h = pip_height,
        w = pip_width,
        x = (1 - 0.162),
        y = ((1 - pip_height) - padding),
    }),

    pip_top_right = hs.geometry({
        h = pip_height,
        w = pip_width,
        x = padding,
        y = padding,
    }),
}

--- Retrieves configuration value with support for nested parameters.
local function get_config(...)
    local args = { ... }
    local value = nil
    for _, param in ipairs(args) do
        if value == nil then
            value = obj.config[param]
        else
            value = value[param]
        end
        if value == nil then
            error(string.format("Invalid parameter: %s", param))
        end
    end
    return value
end

-- Gets the layout index for a given `application_name` and `layout`, defaulting to `1`.
local function get_application_geometry_index(layout, application_name)
    local layout_state = obj.state[layout]
    if layout_state == nil then
        layout_state = { application_name = 1 }
        obj.state[layout] = layout_state
    end

    if layout_state[application_name] == nil then
        layout_state[application_name] = 1
    end

    return layout_state[application_name]
end

local function set_application_geometry_index(layout, application_name, index)
    if obj.state[layout] == nil then
        obj.state[layout] = {}
        obj.state[layout][application_name] = index
        return
    end
    obj.state[layout][application_name] = index
end

--- Traverse `table` by `step` wrapping around to the beginning and end of the table.
--
-- If Lua arrays had a 0-based index, then this would be simple using the modulus operator,
-- however, instead we have to do this hacky workaround. See another user with the same
-- bewilderment: https://devforum.roblox.com/t/wrapping-index-in-an-array/1476197/2
--
-- @param table table table to traverse
-- @param index integer current index of table
-- @param step integer positive or negative value to iterate over table
--
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

    local _active_layout = self.layouts[self.layout]

    local current_index = get_application_geometry_index(self.layout, focused_application_name)
    local next_index = next_index_circular(_active_layout, current_index, direction)
    set_application_geometry_index(self.layout, focused_application_name, next_index)

    local target_geometry = _active_layout[next_index]
    focused_window:moveToUnit(target_geometry)
end

function obj:set_layout(layout)
    self.layout = layout
    local active_layout = self.layouts[layout]

    -- NOTE: Getting windows on each layout change can be removed if window creation stores window in state
    local active_windows = self.window_filter_all:getWindows()
    for _, window in ipairs(active_windows) do
        -- Non-blocking `moveToUnit` by using timers
        hs.timer.doAfter(0, function()
            -- Disabling `AXEnhancedUserInterface` fixes the issue where applications like Firefox
            -- require multiple retries to resize. Ideally, we would re-set this value to `true` after
            -- resizing the window, as it's required for voice controls, but for now we'll just set it
            -- once.
            --
            -- See: https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-2155567633
            -- See: https://github.com/Hammerspoon/hammerspoon/issues/3624
            local app_name = window:application():name()
            local axApp = hs.axuielement.applicationElement(window:application())
            if axApp.AXEnhancedUserInterface then
                axApp.AXEnhancedUserInterface = false
            end

            -- obj.state[layout][application_name]

            local ix = get_application_geometry_index(layout, app_name)
            local target_geometry = active_layout[ix]
            window:moveToUnit(target_geometry)
        end)
    end
end

function obj:save_state()
    local path = get_config("state_file_path")
    hs.json.write(self.state, path, true, true)
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

    self.layout = get_config("default_layout")
    self.layouts = get_config("layouts")

    -- Automatic layout application to new/focused windows.
    self.window_filter_all = hs.window.filter.new()

    -- Consider usage of `windowCreated` and `windowFocused` for ideal resizing trigger
    -- TODO refactor this so that movement and getting layout is shared
    self.window_filter_all:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        -- Prevent resizing of floating windows
        --
        -- http://www.hammerspoon.org/docs/hs.window.html#isStandard
        --
        --  > "Standard window" means that this is not an unusual popup window, a modal dialog, a floating window, etc.
        --
        if window:isStandard() then
            hs.alert("Initializing " .. app_name)
            local ix = get_application_geometry_index(self.layout, app_name)
            local target_geometry = self.layouts[self.layout][ix]
            window:moveToUnit(target_geometry)
        end
    end)

    -- bind layouts to corresponding 1, 2, ..., n
    for key, _ in pairs(self.layouts) do
        hs.hotkey.bind({ "cmd", "ctrl" }, tostring(key), function()
            obj:set_layout(key)
        end)
    end

    --- Display cached state window geometries for active layout
    local function hs_alert_window_state()
        if obj.state[self.layout] == nil then
            hs.alert(string.format("No state for layout: %s", self.layout))
            return
        end
        local lines = {}
        lines[#lines + 1] = string.format("Active Layout: %s", self.layout)
        lines[#lines + 1] = string.rep("-", 80)
        for application, geometry_index in pairs(obj.state[self.layout]) do
            lines[#lines + 1] = string.format("%-40s %40s", application, geometry_index)
        end
        hs.alert(table.concat(lines, "\n"))
    end

    local _prefix = get_config("bindings", "prefix")

    hs.hotkey.bind(_prefix, get_config("bindings", "cycle_right"), function()
        self:move_focused_window_next_geometry(1)
    end)
    hs.hotkey.bind(_prefix, get_config("bindings", "cycle_left"), function()
        self:move_focused_window_next_geometry(-1)
    end)
    hs.hotkey.bind(_prefix, get_config("bindings", "state_alert"), function()
        hs_alert_window_state()
    end)
    hs.hotkey.bind(_prefix, get_config("bindings", "state_save"), function()
        self:save_state()
    end)
    hs.hotkey.bind(_prefix, get_config("bindings", "state_restore"), function()
        self:load_state()
    end)

    local function moveToScreen(index)
        local screens = hs.screen.allScreens()
        hs.window.focusedWindow():moveToScreen(screens[index])
    end

    -- todo - move to next / previous screen
    hs.hotkey.bind({ "cmd", "ctrl" }, "h", function()
        moveToScreen(1)
    end)

    hs.hotkey.bind({ "cmd", "ctrl" }, "l", function()
        moveToScreen(2)
    end)
end

return obj
