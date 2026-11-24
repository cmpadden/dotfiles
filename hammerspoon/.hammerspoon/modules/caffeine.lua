local obj = {}
local width, height = 200, 40
local hold = 1.2
local open_duration, close_duration = 0.21, 0.16
local hud, timer
local progress, reduce_motion

local function stop_timer()
    if timer then
        timer:stop()
        timer = nil
    end
end

local function dismiss_hud()
    stop_timer()
    if hud then
        hud:delete()
        hud = nil
    end
end

local function system_reduces_motion()
    local value =
        hs.execute("/usr/bin/defaults read com.apple.universalaccess reduceMotion 2>/dev/null")
    return value:match("^%s*1%s*$") ~= nil
end

local function render(fraction)
    progress = fraction
    if reduce_motion then
        hud:alpha(fraction)
        return
    end

    -- Width leads height so the island opens sideways before settling vertically.
    -- The label fades in at a fixed font size once the silhouette can contain it.
    local remaining = 1 - fraction
    local w = width - (width - 34) * remaining ^ 3
    local h = height - (height - 14) * remaining ^ 2
    hud[1].frame = { x = (width - w) / 2, y = (height - h) / 2, w = w, h = h }
    hud[1].roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 }
    local text_alpha = math.max(0, math.min(1, (fraction - 0.32) / 0.4))
    hud[2].textColor = { white = 1, alpha = text_alpha ^ 2 * (3 - 2 * text_alpha) }
    hud:alpha(math.min(1, fraction * 5))
end

local function animate_to(target, duration, on_done)
    stop_timer()
    local start = progress
    local seconds = duration * math.abs(target - start)
    if seconds == 0 then
        on_done()
        return
    end
    local started = hs.timer.absoluteTime()
    timer = hs.timer.doEvery(1 / 60, function()
        local elapsed = (hs.timer.absoluteTime() - started) / 1e9
        local t = math.min(1, elapsed / seconds)
        render(start + (target - start) * t)
        if t == 1 then
            stop_timer()
            on_done()
        end
    end)
end

-- Reuse the current HUD on quick toggles, even if it is still moving.
local function show_hud(title, position)
    local screen = hs.screen.mainScreen()
    if not screen then
        dismiss_hud()
        return
    end
    local frame = screen:frame()
    local inset = math.min(96, frame.h * 0.12)
    local x = frame.x + (frame.w - width) / 2
    local y = position == "top" and frame.y + 12 or frame.y + frame.h - inset - height
    local previous = hud and hud:frame()
    if previous and previous.x == x and previous.y == y then
        hud[2].text = title
    else
        dismiss_hud()
        reduce_motion = system_reduces_motion()
        local font, size = ".AppleSystemUIFont", 14
        local text = hs.drawing.getTextDrawingSize(title, { font = font, size = size })
        hud = hs.canvas.new({ x = x, y = y, w = width, h = height })
        hud:appendElements({
            type = "rectangle",
            action = "fill",
            roundedRectRadii = { xRadius = height / 2, yRadius = height / 2 },
            fillColor = { white = 0.12 },
        }, {
            type = "text",
            text = title,
            textFont = font,
            textSize = size,
            textColor = { white = 1 },
            textAlignment = "center",
            frame = { x = 0, y = (height - text.h) / 2, w = width, h = math.ceil(text.h) },
        })
        render(0)
        hud:level(hs.canvas.windowLevels.overlay):show()
    end

    animate_to(1, reduce_motion and 0.15 or open_duration, function()
        timer = hs.timer.doAfter(hold, function()
            animate_to(0, reduce_motion and 0.18 or close_duration, dismiss_hud)
        end)
    end)
end

function obj.bind(modifiers, key, options)
    local position = (options or {}).position or "bottom"
    assert(
        position == "top" or position == "bottom",
        'Caffeine HUD position must be "top" or "bottom"'
    )
    return hs.hotkey.bind(modifiers, key, function()
        hs.caffeinate.toggle("displayIdle")
        local enabled = hs.caffeinate.get("displayIdle")
        show_hud(enabled and "Caffeine Enabled" or "Caffeine Disabled", position)
    end)
end

return obj
