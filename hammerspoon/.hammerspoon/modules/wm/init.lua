--- Window management
--
-- Public API (unchanged from the previous modules/window.lua):
--
--   local wm = require("modules.wm")
--   wm.config.application_ignore_list = { ... }
--   wm.config.layouts = { { wm.builtins.full }, ... }
--   wm:init()
--
-- Tracking:
-- - [ ] Multi-monitor support
-- - [x] Differing geometries for multiple windows in the same application
-- - [x] Parameterize animation disable

local actions = require("modules.wm.actions")
local geometry = require("modules.wm.geometry")
local state = require("modules.wm.state")
local util = require("modules.wm.util")

local obj = {
    name = "wm",
    log = hs.logger.new("wm", "warning"),
    builtins = geometry.builtins,
    config = {
        default_layout = 2,
        state_file_path = os.getenv("HOME") .. "/.hammerspoon/_wm.spoon.state.json",
        animation_duration = 0,
        -- hs.window.setFrameCorrectness re-verifies every move and is a known
        -- slow path; the AXEnhancedUserInterface fix in actions.lua already
        -- addresses the Firefox resize issue it was originally enabled for.
        set_frame_correctness = false,
        -- Persist window state via hs.shutdownCallback and restore it on init.
        auto_persist_state = true,
        layouts = {},
        application_ignore_list = {},
        bindings = {
            prefix = { "cmd", "shift" },
            cycle_left = "h",
            cycle_right = "l",
            state_save = "-",
            state_restore = "=",
            state_alert = "/",
            layout_prefix = { "cmd", "ctrl" },
            screen_prefix = { "cmd", "ctrl" },
            screen_left = "h",
            screen_right = "l",
        },
    },
    _hotkeys = {},
    _ignore_set = {},
}

--- Retrieve a configuration value, raising with the full key path when missing.
local function get_config(...)
    local value = obj.config
    local path = {}
    for _, key in ipairs({ ... }) do
        path[#path + 1] = tostring(key)
        value = value[key]
        if value == nil then
            error(string.format("wm: missing config value: %s", table.concat(path, ".")))
        end
    end
    return value
end

--- Set of window keys for currently manageable windows.
local function active_window_keys()
    local keys = {}
    for _, window in ipairs(hs.window.allWindows()) do
        if util.is_manageable(window) then
            local window_key = util.window_key(window)
            if window_key then
                keys[window_key] = true
            end
        end
    end
    return keys
end

function obj:is_ignored(window)
    local app = util.app_name(window)
    return app ~= nil and self._ignore_set[app] == true
end

function obj:move_focused_window_next_geometry(direction)
    actions.cycle_focused_window(self, direction)
end

function obj:set_layout(layout)
    actions.set_layout(self, layout)
end

function obj:save_state(quiet)
    self.state:cleanup(active_window_keys())
    local ok, err = self.state:save()
    if quiet then
        return
    end
    if ok then
        hs.alert(string.format("wm state written to file: %s", get_config("state_file_path")))
    else
        hs.alert(err)
    end
end

function obj:load_state(quiet)
    local ok, err = self.state:load()
    if quiet then
        return
    end
    if ok then
        hs.alert(string.format("wm state loaded from file: %s", get_config("state_file_path")))
    else
        hs.alert(err)
    end
end

--- Display cached state window geometries for the active layout.
function obj:alert_window_state()
    local layout_state = self.state:layout_state(self.layout)
    if layout_state == nil or next(layout_state) == nil then
        hs.alert(string.format("No state for layout: %s", self.layout))
        return
    end
    local lines = {}
    lines[#lines + 1] = string.format("Active Layout: %s", self.layout)
    lines[#lines + 1] = string.rep("-", 80)
    for window_key, geometry_index in pairs(layout_state) do
        lines[#lines + 1] = string.format("%-40s %40s", window_key, geometry_index)
    end
    hs.alert(table.concat(lines, "\n"))
end

--- Create the window filter and subscriptions.
--
-- Deferred out of init() because an unrestricted hs.window.filter is the most
-- expensive part of startup (~40ms); hotkeys become available immediately and
-- the filter warms up just after load.
function obj:_start_window_filter()
    self._filter = hs.window.filter.new()

    -- Apply the active layout's geometry to newly created manageable windows.
    self._filter:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        if self:is_ignored(window) then
            self.log.df("ignoring new window from %s (in ignore list)", app_name)
            return
        end

        if util.is_manageable(window) then
            self.log.df("initializing window from %s", app_name)
            local window_key = util.window_key(window)
            if not window_key then
                return
            end
            local geometries = self.layouts[self.layout] or {}
            local index = self.state:get_index(self.layout, window_key)
            if index > #geometries then
                index = 1
            end
            actions.apply_geometry(self, window, self.layout, index)
        end
    end)

    -- Clean up state when windows are closed.
    self._filter:subscribe(hs.window.filter.windowDestroyed, function(window)
        local window_key = util.window_key(window)
        if window_key then
            self.state:remove_window(window_key)
        end
    end)

    -- Prune state entries for windows that no longer exist.
    self.state:cleanup(active_window_keys())
end

--- Remove hotkeys, subscriptions, and timers so init() is re-entrant.
function obj:stop()
    for _, hotkey in ipairs(self._hotkeys) do
        hotkey:delete()
    end
    self._hotkeys = {}
    if self._filter then
        self._filter:unsubscribeAll()
        self._filter = nil
    end
    if self._filter_timer then
        self._filter_timer:stop()
        self._filter_timer = nil
    end
end

function obj:init()
    self:stop()

    hs.window.animationDuration = get_config("animation_duration")
    hs.window.setFrameCorrectness = get_config("set_frame_correctness")

    self.layout = get_config("default_layout")
    self.layouts = get_config("layouts")
    self._ignore_set = util.build_set(self.config.application_ignore_list)
    self.state = state.new(get_config("state_file_path"))

    if get_config("auto_persist_state") then
        self:load_state(true)
        -- Note: hs.shutdownCallback is a single global slot; this assumes no
        -- other module claims it. It fires on both quit and config reload.
        hs.shutdownCallback = function()
            obj:save_state(true)
        end
    end

    local function bind(mods, key, fn)
        self._hotkeys[#self._hotkeys + 1] = hs.hotkey.bind(mods, key, fn)
    end

    -- Bind layouts to layout_prefix + 1, 2, ..., n.
    local layout_prefix = get_config("bindings", "layout_prefix")
    for key in pairs(self.layouts) do
        bind(layout_prefix, tostring(key), function()
            obj:set_layout(key)
        end)
    end

    local prefix = get_config("bindings", "prefix")
    bind(prefix, get_config("bindings", "cycle_right"), function()
        self:move_focused_window_next_geometry(1)
    end)
    bind(prefix, get_config("bindings", "cycle_left"), function()
        self:move_focused_window_next_geometry(-1)
    end)
    bind(prefix, get_config("bindings", "state_alert"), function()
        self:alert_window_state()
    end)
    bind(prefix, get_config("bindings", "state_save"), function()
        self:save_state()
    end)
    bind(prefix, get_config("bindings", "state_restore"), function()
        self:load_state()
    end)

    local screen_prefix = get_config("bindings", "screen_prefix")
    bind(screen_prefix, get_config("bindings", "screen_left"), function()
        actions.move_focused_window_one_screen(-1)
    end)
    bind(screen_prefix, get_config("bindings", "screen_right"), function()
        actions.move_focused_window_one_screen(1)
    end)

    self._filter_timer = hs.timer.doAfter(0, function()
        self:_start_window_filter()
        -- Apply the restored active layout to windows that already existed
        -- when Hammerspoon started; windowCreated only covers future windows.
        self:set_layout(self.layout)
    end)
end

return obj
