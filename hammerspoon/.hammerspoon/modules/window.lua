local obj = {}
obj.__index = obj

obj.name = "Window Management"
obj.version = "1.0.0"

obj.config = {
    ["default-layout"] = 3,
    ["split-padding"] = 0.08,
    padding = 0.02,
    ["window-width-centered"] = 0.65,
    ["window-width-skinny"] = 0.35,
}

RECT_CENTER = hs.geometry({
    h = (1 - (2 * obj.config.padding)),
    w = obj.config["window-width-centered"],
    x = ((1 - obj.config["window-width-centered"]) / 2),
    y = obj.config.padding,
})

RECT_LEFT = hs.geometry({
    h = (1 - (2 * obj.config.padding)),
    w = (0.5 - (obj.config["split-padding"] + 0.005)),
    x = obj.config["split-padding"],
    y = obj.config.padding,
})

RECT_RIGHT = hs.geometry({
    h = (1 - (2 * obj.config.padding)),
    w = (0.5 - obj.config["split-padding"] - 0.005),
    x = (0.5 + 0.005),
    y = obj.config.padding,
})

RECT_SKINNY = hs.geometry({
    h = (1 - (2 * obj.config.padding)),
    w = obj.config["window-width-skinny"],
    x = ((1 - obj.config["window-width-skinny"]) / 2),
    y = obj.config.padding,
})

PIP_BOTTOM_RIGHT = hs.geometry({
    h = 0.35,
    w = 0.142,
    x = (1 - 0.162),
    y = ((1 - 0.35) - obj.config.padding),
})

PIP_TOP_RIGHT = hs.geometry({
    h = 0.35,
    w = 0.142,
    -- x = (1 - 0.162),
    x = obj.config.padding,
    y = obj.config.padding,
})

-- stylua: ignore start
obj.layouts = {
    [1] = {
        Alacritty           = hs.layout.maximized,
        Arc                 = hs.layout.maximized,
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
        Terminal            = hs.layout.maximized,
        ["Bitwig Studio"]   = hs.layout.maximized,
        ["Brave Browser"]   = hs.layout.maximized,
        ["Google Chrome"]   = hs.layout.maximized,
        ["Logic Pro"]       = hs.layout.maximized,
        ["Notion Calendar"] = hs.layout.maximized,
        ["zoom.us"]         = hs.layout.maximized,
        kitty               = hs.layout.maximized,
        Linear              = hs.layout.maximized,
    },
    [2] = {
        Alacritty           = RECT_LEFT,
        Arc                 = RECT_RIGHT,
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
        Terminal            = RECT_LEFT,
        ["Bitwig Studio"]   = RECT_LEFT,
        ["Brave Browser"]   = RECT_RIGHT,
        ["Google Chrome"]   = RECT_RIGHT,
        ["Logic Pro"]       = RECT_RIGHT,
        ["Notion Calendar"] = RECT_LEFT,
        ["zoom.us"]         = RECT_RIGHT,
        kitty               = RECT_LEFT,
    },
    [3] = {
        Alacritty           = RECT_CENTER,
        Arc                 = RECT_CENTER,
        Calendar            = RECT_CENTER,
        Chromium            = RECT_CENTER,
        Discord             = RECT_CENTER,
        Figma               = RECT_CENTER,
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
        Terminal            = RECT_CENTER,
        ["Bitwig Studio"]   = RECT_CENTER,
        ["Brave Browser"]   = RECT_CENTER,
        ["Google Chrome"]   = RECT_CENTER,
        ["Logic Pro"]       = RECT_CENTER,
        ["Notion Calendar"] = RECT_CENTER,
        ["zoom.us"]         = RECT_CENTER,
        kitty               = RECT_CENTER,
    },
    [4] = {
        Alacritty           = RECT_SKINNY,
        Arc                 = RECT_SKINNY,
        Calendar            = RECT_SKINNY,
        Chromium            = RECT_SKINNY,
        Discord             = RECT_SKINNY,
        Figma               = RECT_SKINNY,
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
        Terminal            = RECT_SKINNY,
        ["Bitwig Studio"]   = RECT_SKINNY,
        ["Brave Browser"]   = RECT_SKINNY,
        ["Google Chrome"]   = RECT_SKINNY,
        ["Logic Pro"]       = RECT_SKINNY,
        ["Notion Calendar"] = RECT_SKINNY,
        ["zoom.us"]         = RECT_SKINNY,
        kitty               = RECT_SKINNY,
    }
}
-- stylua: ignore end
--

-- Convert relative `unitrect` to `rect` (hs.window:fromUnitRect does not seem to work)
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
    local active_windows = hs.window.filter.default:getWindows()
    for _, w in ipairs(active_windows) do
        local app_name = w:application():name()
        if active_layout[app_name] ~= nil then
            local target_geometry = active_layout[app_name]
            _move_to_unit_with_retries(target_geometry, w)
        end
    end
end

function obj:init()
    hs.window.animationDuration = 0
    -- hs.window.setFrameCorrectness = true
    self.layout = 1

    -- Automatic layout application to new/focused windows.
    --
    -- Consider usage of `windowCreated` and `windowFocused` for ideal resizing trigger
    --
    -- References:
    --     https://www.hammerspoon.org/docs/hs.window.filter.html
    self.window_filter_all = hs.window.filter.new()
    self.window_filter_all:subscribe(hs.window.filter.windowCreated, function(window, app_name)
        local target_geometry = self.layouts[obj.layout][app_name]
        _move_to_unit_with_retries(target_geometry, window)
    end)

    -- bind layouts to corresponding 1, 2, ..., n
    for key, _ in pairs(self.layouts) do
        hs.hotkey.bind({ "cmd", "ctrl" }, tostring(key), function()
            obj:set_layout(key)

            -- explore hs.timer:doUntil and validate window positions
            -- get window dimensions before, validate that size is same
            hs.timer:doAfter(2, function()
                obj:set_layout(key)
            end)
        end)
    end
end

return obj
