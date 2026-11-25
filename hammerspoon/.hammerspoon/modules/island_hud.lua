local obj = {}
local width, height = 200, 40
local hold = 1.2
local open_duration, close_duration = 0.21, 0.16
local top_gap = 20
local matte = { white = 0.12 }
local label_font, label_size, label_white = ".AppleSystemUIFontMedium", 13, 0.96
local hud, timer, label_timer
local phase, reduce_motion, drip, exit_progress
local label, pending_label, label_height, label_top
local label_alpha, label_visibility

function obj.dismiss()
    if timer then
        timer:stop()
        timer = nil
    end
    if label_timer then
        label_timer:stop()
        label_timer = nil
    end
    pending_label = nil
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
    -- Keep the neck inside the capsule as it narrows; retracting its tip
    -- toward the edge would leave a separate sliver before it disappears.
    local tail = 1 - smoothstep((fraction - 0.46) / 0.25)
    local depth = top + h / 2
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

local function position_label()
    hud[3].frame = { x = 0, y = label_top - label_height / 2, w = width, h = label_height }
end

local function paint_label()
    hud[3].textColor = { white = label_white, alpha = label_alpha * label_visibility }
end

local function set_label(title)
    label = title
    label_height =
        math.ceil(hs.drawing.getTextDrawingSize(title, { font = label_font, size = label_size }).h)
    hud[3].text = title
    position_label()
end

local function render_capsule(w, h, top)
    hud[2].frame = { x = (width - w) / 2, y = top, w = w, h = h }
    hud[2].roundedRectRadii = { xRadius = h / 2, yRadius = h / 2 }
    label_top = top + h / 2
    position_label()
end

local function render_expansion(fraction, opacity)
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
    end
    render_capsule(w, h, top)
    label_visibility = smoothstep((fraction - 0.32) / 0.4)
    paint_label()
    hud:alpha(opacity or math.min(1, fraction * 5))
end

local function render_exit(fraction)
    exit_progress = fraction
    local t = smoothstep(fraction)
    if drip then
        -- Retrace the liquid path at full opacity. At zero expansion the
        -- capsule is above the canvas and there is no tether left to draw.
        render_expansion(1 - t, 1)
        return
    end
    if not reduce_motion then
        local h = height - 9 * t
        render_capsule(width - 54 * t, h, (height - h) / 2)
        label_visibility = 1 - smoothstep(t / 0.65)
        paint_label()
    end
    hud:alpha(1 - t)
end

local function animate(seconds, render, on_done)
    local started = hs.timer.absoluteTime()
    local animation
    animation = hs.timer.doEvery(1 / 60, function()
        local elapsed = (hs.timer.absoluteTime() - started) / 1e9
        local t = math.min(1, elapsed / seconds)
        render(t)
        if t == 1 then
            animation:stop()
            on_done()
        end
    end)
    return animation
end

local function fade_label_to(target, seconds, on_done)
    local start = label_alpha
    if start == target then
        on_done()
        return
    end
    label_timer = animate(seconds * math.abs(target - start), function(t)
        label_alpha = start + (target - start) * smoothstep(t)
        paint_label()
    end, function()
        label_timer = nil
        on_done()
    end)
end

local function update_label(title)
    if pending_label then
        -- An update during fade-out replaces the pending text, not the timer.
        pending_label = title
    elseif title ~= label then
        if label_timer then
            label_timer:stop()
            label_timer = nil
        end
        if label_visibility == 0 then
            set_label(title)
            label_alpha = 1
            paint_label()
            return
        end
        pending_label = title
        fade_label_to(0, 0.06, function()
            set_label(pending_label)
            pending_label = nil
            fade_label_to(1, 0.09, function() end)
        end)
    end
end

local function begin_hold()
    phase = "holding"
    timer = hs.timer.doAfter(hold, function()
        phase = "closing"
        local closing = reduce_motion and 0.18 or (drip and 0.24 or close_duration)
        timer = animate(closing, render_exit, function()
            timer = nil
            obj.dismiss()
        end)
    end)
end

local function refresh(title)
    update_label(title)
    if phase == "holding" then
        timer:stop()
        begin_hold()
    elseif phase == "closing" then
        timer:stop()
        phase = "opening"
        local start = exit_progress
        if start == 0 then
            begin_hold()
        else
            timer = animate(0.18 * start, function(t)
                render_exit(start * (1 - t))
            end, begin_hold)
        end
    end
end

-- Reuse the current HUD for successive messages, even if it is still moving.
function obj.show(title, position)
    assert(position == "top" or position == "bottom", 'HUD position must be "top" or "bottom"')
    local screen = hs.screen.mainScreen()
    if not screen then
        obj.dismiss()
        return
    end
    local frame = screen:frame()
    local inset = math.min(96, frame.h * 0.12)
    local x = frame.x + (frame.w - width) / 2
    local at_top = position == "top"
    local y = at_top and frame.y or frame.y + frame.h - inset - height
    local previous = hud and hud:frame()
    if previous and previous.x == x and previous.y == y then
        refresh(title)
        return
    end

    obj.dismiss()
    reduce_motion = system_reduces_motion()
    drip = at_top and not reduce_motion
    local gap = at_top and top_gap or 0
    hud = hs.canvas.new({ x = x, y = y, w = width, h = height + gap })
    hud:appendElements({
        type = "segments",
        action = "skip",
        closed = true,
        fillColor = matte,
    }, {
        type = "rectangle",
        action = "fill",
        fillColor = matte,
    }, {
        type = "text",
        textFont = label_font,
        textSize = label_size,
        textAlignment = "center",
    })
    label_alpha, label_visibility = 1, 1
    exit_progress = 0
    label_top = gap + height / 2
    set_label(title)
    render_capsule(width, height, gap)
    paint_label()
    render_expansion(0)
    hud:level(hs.canvas.windowLevels.overlay):show()

    phase = "opening"
    local opening = reduce_motion and 0.15 or (drip and 0.25 or open_duration)
    timer = animate(opening, render_expansion, begin_hold)
end

return obj
