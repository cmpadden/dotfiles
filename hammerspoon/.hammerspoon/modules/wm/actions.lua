--- Window operations shared by hotkeys and window-filter subscriptions.

local util = require("modules.wm.util")

local M = {}

-- Applications whose AXEnhancedUserInterface attribute has already been
-- disabled this session, keyed by process id.
local ax_disabled_pids = {}

--- Disable `AXEnhancedUserInterface` for the window's application.
--
-- Fixes applications like Firefox requiring multiple retries to resize.
-- Ideally we would restore the value after resizing (it is used by voice
-- controls), but for now it is disabled once per application per session.
--
-- See: https://github.com/Hammerspoon/hammerspoon/issues/3224#issuecomment-2155567633
-- See: https://github.com/Hammerspoon/hammerspoon/issues/3624
function M.disable_ax_enhanced_ui(window)
    local ok, pid = pcall(function()
        return window:application():pid()
    end)
    if not ok or not pid or ax_disabled_pids[pid] then
        return
    end
    ax_disabled_pids[pid] = true

    local ax_app = hs.axuielement.applicationElement(window:application())
    if ax_app and ax_app.AXEnhancedUserInterface then
        ax_app.AXEnhancedUserInterface = false
    end
end

--- Move `window` to the geometry at `index` in `layout`.
-- @return boolean whether the move succeeded
function M.apply_geometry(wm, window, layout, index)
    local geometries = wm.layouts[layout]
    local target = geometries and geometries[index]
    if not target then
        return false
    end
    M.disable_ax_enhanced_ui(window)
    return (pcall(function()
        window:moveToUnit(target)
    end))
end

--- Cycle the focused window through the active layout's geometries.
function M.cycle_focused_window(wm, step)
    local window = hs.window.focusedWindow()
    if not window or wm:is_ignored(window) then
        return
    end

    local window_key = util.window_key(window)
    if not window_key then
        return
    end

    local geometries = wm.layouts[wm.layout]
    if not geometries or #geometries == 0 then
        return
    end

    local current = wm.state:get_index(wm.layout, window_key)
    if current > #geometries then
        current = 1
    end
    local next_index = util.circular_index(#geometries, current, step)
    wm.state:set_index(wm.layout, window_key, next_index)
    M.apply_geometry(wm, window, wm.layout, next_index)
end

--- Activate `layout` and move every manageable window to its slot.
function M.set_layout(wm, layout)
    local geometries = wm.layouts[layout]
    if not geometries then
        wm.log.ef("layout %s not found", tostring(layout))
        return
    end

    wm.layout = layout

    local moved = 0
    for _, window in ipairs(hs.window.allWindows()) do
        if util.is_manageable(window) then
            local app = util.app_name(window) or "unknown"
            if wm:is_ignored(window) then
                wm.log.df("ignoring %s (in ignore list)", app)
            else
                local window_key = util.window_key(window)
                if window_key then
                    local index = wm.state:get_index(layout, window_key)
                    if index > #geometries then
                        index = 1
                        wm.state:set_index(layout, window_key, index)
                    end
                    if M.apply_geometry(wm, window, layout, index) then
                        moved = moved + 1
                    else
                        wm.log.wf("failed to move window from %s", app)
                    end
                end
            end
        end
    end

    wm.log.df("layout %d applied to %d windows", layout, moved)
end

--- Move the focused window one screen west (step < 0) or east (step > 0).
--
-- Safe on single-display setups (no-op) and independent of the unstable
-- ordering of hs.screen.allScreens().
function M.move_focused_window_one_screen(step)
    local window = hs.window.focusedWindow()
    if not window then
        return
    end
    if step < 0 then
        window:moveOneScreenWest(false, true)
    else
        window:moveOneScreenEast(false, true)
    end
end

return M
