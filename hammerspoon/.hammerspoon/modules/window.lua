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
LAYOUTS = {
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

--- Callback to automatically position a launched application to the desired layout.
---
--- Reference:
--- https://www.hammerspoon.org/docs/hs.application.watcher.html
local function set_application_layout_callback(app_name, event_type, app)
    if event_type == hs.application.watcher.launched then
        repeat
        until app:mainWindow() -- app:mainWindow() will be `nil` until fully loaded
        app:mainWindow():moveToUnit(LAYOUTS[obj.layout][app_name])
    end
end

function obj:set_layout(layout)
    self.layout = layout
    local active_layout = LAYOUTS[layout]
    local active_windows = (hs.window.filter.default):getWindows()
    for _, w in ipairs(active_windows) do
        local app_name = w:application():name()
        if active_layout[app_name] ~= nil then
            w:moveToUnit(active_layout[app_name])
        else
        end
    end
end

function obj:init()
    hs.window.animationDuration = 0
    self.layout = 1
    self.application_watcher = hs.application.watcher.new(set_application_layout_callback)
    self.application_watcher:start()

    -- bind layouts to corresponding 1, 2, ..., n
    for key, _ in pairs(LAYOUTS) do
        hs.hotkey.bind({ "cmd", "ctrl" }, tostring(key), function()
            obj:set_layout(key)
        end)
    end
end

return obj
