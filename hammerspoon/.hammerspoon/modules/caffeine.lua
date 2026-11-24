local obj = {}
local width, height = 200, 40
local hold = 1.2
local open_duration, close_duration = 0.21, 0.16
local top_gap = 20
local matte = { white = 0.12 }
local hud, timer
local progress, reduce_motion, drip, label_height

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

local function smoothstep(t)
    t = math.max(0, math.min(1, t))
    return t ^ 2 * (3 - 2 * t)
end

-- Pull a curved neck between the screen edge and the capsule, then pinch it off.
-- The tether is drawn behind the capsule so their overlap reads as one shape.
local function render_tether(fraction, top, w, h)
    local tail = 1 - smoothstep((fraction - 0.52) / 0.23)
    local depth = (top + h / 2) * tail
    if depth <= 0 or tail == 0 then
        hud[1].action = "skip"
        return
    end

    local pinch = 1 - smoothstep((fraction - 0.23) / 0.37)
    local center = width / 2
    local shoulder = (16 + 10 * pinch) * tail
    local neck = (0.35 + 12 * pinch) * tail
    local join = (0.35 + math.min(w * 0.3, 32) * pinch) * tail
    local function point(x, y, cx1, cy1, cx2, cy2)
        if cx1 then
            return {
                x = center + x,
                y = y,
                c1x = center + cx1,
                c1y = cy1,
                c2x = center + cx2,
                c2y = cy2,
            }
        end
        return { x = center + x, y = y }
    end
    hud[1].coordinates = {
        point(-shoulder, 0),
        point(shoulder, 0),
        point(neck, depth * 0.48, neck, 0, neck, depth * 0.24),
        point(join, depth, neck, depth * 0.78, join, depth * 0.88),
        point(-join, depth),
        point(-neck, depth * 0.48, -join, depth * 0.88, -neck, depth * 0.78),
        point(-shoulder, 0, -neck, depth * 0.24, -neck, 0),
    }
    hud[1].action = "fill"
end

local function render(fraction)
    progress = fraction
    if reduce_motion then
        hud:alpha(fraction)
        return
    end

    -- Width leads height, and the label always keeps its original font size.
    local remaining = 1 - fraction
    local w = width - (width - 34) * remaining ^ 3
    local h = height - (height - 14) * remaining ^ 2
    local top = (height - h) / 2
    if drip then
        top = top_gap - (top_gap + 14) * remaining ^ 2
        render_tether(fraction, top, w, h)
        hud[3].frame = { x = 0, y = top + (h - label_height) / 2, w = width, h = label_height }
    end
    hud[2].frame = { x = (width - w) / 2, y = top, w = w, h = h }
    hud[2].roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 }
    hud[3].textColor = { white = 1, alpha = smoothstep((fraction - 0.32) / 0.4) }
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
    local at_top = position == "top"
    local y = at_top and frame.y or frame.y + frame.h - inset - height
    local previous = hud and hud:frame()
    if previous and previous.x == x and previous.y == y then
        hud[3].text = title
    else
        dismiss_hud()
        reduce_motion = system_reduces_motion()
        drip = at_top and not reduce_motion
        local gap = at_top and top_gap or 0
        local font, size = ".AppleSystemUIFont", 14
        label_height =
            math.ceil(hs.drawing.getTextDrawingSize(title, { font = font, size = size }).h)
        hud = hs.canvas.new({ x = x, y = y, w = width, h = height + gap })
        hud:appendElements({
            type = "segments",
            action = "skip",
            closed = true,
            fillColor = matte,
        }, {
            type = "rectangle",
            action = "fill",
            frame = { x = 0, y = gap, w = width, h = height },
            roundedRectRadii = { xRadius = height / 2, yRadius = height / 2 },
            fillColor = matte,
        }, {
            type = "text",
            text = title,
            textFont = font,
            textSize = size,
            textColor = { white = 1 },
            textAlignment = "center",
            frame = { x = 0, y = gap + (height - label_height) / 2, w = width, h = label_height },
        })
        render(0)
        hud:level(hs.canvas.windowLevels.overlay):show()
    end

    local opening = reduce_motion and 0.15 or (drip and 0.25 or open_duration)
    local closing = reduce_motion and 0.18 or (drip and 0.19 or close_duration)
    animate_to(1, opening, function()
        timer = hs.timer.doAfter(hold, function()
            animate_to(0, closing, dismiss_hud)
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
