--- Window Management
--
-- Tracking:
-- - [ ] Multi-monitor support
-- - [x] Differing geometries for multiple windows in the same application
-- - [x] Parameterize animation disable

local obj = {
    name = "wm.spoon",
    config = {
        default_layout = 2,
        state_file_path = os.getenv("HOME") .. "/.hammerspoon/_wm.spoon.state.json",
        animation_duration = 0,
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
    -- Store the most layout index for each window in each layout
    state = {
        -- [1] = { "window_id_1" = 1, "window_id_2" = 1 }
        -- [2] = { "window_id_1" = 1, "window_id_2" = 3 }
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

    full_left = hs.geometry({
        h = 1,
        w = 0.5,
        x = 0,
        y = 0,
    }),

    full_right = hs.geometry({
        h = 1,
        w = 0.5,
        x = 0.5,
        y = 0,
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

local function ensure_layout_state(layout)
    if obj.state[layout] == nil then
        obj.state[layout] = {}
    end
    return obj.state[layout]
end

local function get_window_geometry_index(layout, window_id)
    local layout_state = ensure_layout_state(layout)
    return layout_state[window_id] or 1
end

local function set_window_geometry_index(layout, window_id, index)
    local layout_state = ensure_layout_state(layout)
    layout_state[window_id] = index
end

local function get_window_id(window)
    local success, app_name = pcall(function()
        return window:application():name()
    end)
    if not success or not app_name then
        app_name = "unknown"
    end

    local success2, window_id = pcall(function()
        return window:id()
    end)
    if not success2 or not window_id then
        window_id = 0
    end

    return string.format("%s_%d", app_name, window_id)
end

local function cleanup_stale_window_state()
    local all_windows = hs.window.allWindows()
    local active_window_ids = {}

    for _, window in ipairs(all_windows) do
        if window:isStandard() and window:isMaximizable() then
            active_window_ids[get_window_id(window)] = true
        end
    end

    for layout_id, layout_state in pairs(obj.state) do
        for window_id, _ in pairs(layout_state) do
            if not active_window_ids[window_id] then
                layout_state[window_id] = nil
            end
        end
    end
end

local function disable_ax_enhanced_ui(window)
    -- Disabling `AXEnhancedUserInterface` fixes the issue where applications like Firefox
    -- require multiple retries to resize. Ideally, we would re-set this value to `true` after
    -- resizing the window, as it's required for voice controls, but for now we'll just set it
    -- once.
    --
    -- See: https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-2155567633
    -- See: https://github.com/Hammerspoon/hammerspoon/issues/3624
    local axApp = hs.axuielement.applicationElement(window:application())
    if axApp.AXEnhancedUserInterface then
        axApp.AXEnhancedUserInterface = false
    end
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
    local focused_window_id = get_window_id(focused_window)

    local _active_layout = self.layouts[self.layout]

    local current_index = get_window_geometry_index(self.layout, focused_window_id)
    local next_index = next_index_circular(_active_layout, current_index, direction)
    set_window_geometry_index(self.layout, focused_window_id, next_index)

    disable_ax_enhanced_ui(focused_window)
    local target_geometry = _active_layout[next_index]
    focused_window:moveToUnit(target_geometry)
end

function obj:set_layout(layout)
    print(string.format("=== Setting Layout %d ===", layout))
    self.layout = layout
    local active_layout = self.layouts[layout]

    if not active_layout then
        print(string.format("ERROR: Layout %d not found in layouts table", layout))
        return
    end

    print(string.format("Layout %d has %d geometry positions", layout, #active_layout))

    -- Skip all validation and just try to move all windows
    local all_windows = hs.window.allWindows()

    print(string.format("Found %d total windows, attempting to move all", #all_windows))

    local moved_count = 0
    for i, window in ipairs(all_windows) do
        if window and type(window) == "userdata" then
            -- Try to get app name for logging, but don't filter based on it
            local app_success, app_name = pcall(function()
                return window:application():name()
            end)
            local display_name = app_success and app_name or "unknown"

            print(string.format("Window %d: %s - attempting to move", i, display_name))

            -- Try to move the window regardless of validation
            local window_id = get_window_id(window)
            local ix = get_window_geometry_index(layout, window_id)

            if ix > #active_layout then
                ix = 1
                set_window_geometry_index(layout, window_id, ix)
            end

            local target_geometry = active_layout[ix]
            if target_geometry then
                local success, error = pcall(function()
                    window:moveToUnit(target_geometry)
                end)

                if success then
                    print(string.format("  ✓ Successfully moved %s", display_name))
                    moved_count = moved_count + 1
                else
                    print(string.format("  ✗ Failed to move %s: %s", display_name, error))
                end
            end
        end
    end

    print(string.format("=== Layout Setting Complete - Moved %d windows ===", moved_count))
end

function obj:save_state()
    cleanup_stale_window_state()
    local path = get_config("state_file_path")
    hs.json.write(self.state, path, true, true)
    hs.alert(string.format("wm.spoon state written to file: %s", path))
end

function obj:load_state()
    local path = get_config("state_file_path")
    obj.state = hs.json.read(path)
    hs.alert(string.format("wm.spoon state loaded from file: %s", path))
end

function obj:debug_window_filter()
    print("=== Window Filter Debug ===")
    print(string.format("Filter object: %s", tostring(self.window_filter_all)))

    local filter_windows = self.window_filter_all:getWindows()
    local all_windows = hs.window.allWindows()

    print(string.format("Filter returned: %d windows", filter_windows and #filter_windows or 0))
    print(string.format("hs.window.allWindows returned: %d windows", #all_windows))

    print("All windows from hs.window.allWindows():")
    for i, window in ipairs(all_windows) do
        if window and type(window) == "userdata" then
            local success, is_valid = pcall(function()
                return window:isValid()
            end)
            if success and is_valid then
                local app_success, app_name = pcall(function()
                    return window:application():name()
                end)
                local is_standard_success, is_standard = pcall(function()
                    return window:isStandard()
                end)
                local is_max_success, is_maximizable = pcall(function()
                    return window:isMaximizable()
                end)

                print(
                    string.format(
                        "  %d: %s - standard:%s, maximizable:%s",
                        i,
                        app_success and app_name or "unknown",
                        is_standard_success and tostring(is_standard) or "error",
                        is_max_success and tostring(is_maximizable) or "error"
                    )
                )
            else
                print(string.format("  %d: INVALID WINDOW", i))
            end
        else
            print(string.format("  %d: NIL or non-userdata", i))
        end
    end
    print("=== Debug Complete ===")
end

function obj:init()
    hs.window.animationDuration = get_config("animation_duration")
    hs.window.setFrameCorrectness = true

    self.layout = get_config("default_layout")
    self.layouts = get_config("layouts")

    -- Automatic layout application to new/focused windows.
    self.window_filter_all = hs.window.filter.new()
    print(string.format("Window filter initialized: %s", tostring(self.window_filter_all)))

    -- Consider usage of `windowCreated` and `windowFocused` for ideal resizing trigger
    -- TODO refactor this so that movement and getting layout is shared
    self.window_filter_all:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        -- Prevent resizing of floating windows
        --
        -- http://www.hammerspoon.org/docs/hs.window.html#isStandard
        --
        --  > "Standard window" means that this is not an unusual popup window, a modal dialog, a floating window, etc.
        --
        if window:isStandard() and window:isMaximizable() then
            hs.alert("Initializing " .. app_name)
            disable_ax_enhanced_ui(window)
            local window_id = get_window_id(window)
            local ix = get_window_geometry_index(self.layout, window_id)
            local target_geometry = self.layouts[self.layout][ix]
            window:moveToUnit(target_geometry)
        end
    end)

    -- Clean up state when windows are closed
    self.window_filter_all:subscribe(hs.window.filter.windowDestroyed, function(window, app_name)
        local window_id = get_window_id(window)
        for layout_id, layout_state in pairs(obj.state) do
            layout_state[window_id] = nil
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
        for window_id, geometry_index in pairs(obj.state[self.layout]) do
            lines[#lines + 1] = string.format("%-40s %40s", window_id, geometry_index)
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
