local M = {}
local modal, toggle, session
local cell_keys = { "q", "w", "e", "a", "s", "d", "z", "x", "c" }

local function intersection(a, b)
    local x, y = math.max(a.x, b.x), math.max(a.y, b.y)
    local w = math.min(a.x + a.w, b.x + b.w) - x
    local h = math.min(a.y + a.h, b.y + b.h) - y
    if w > 0 and h > 0 then
        return { x = x, y = y, w = w, h = h }
    end
end

local function same_frame(a, b)
    return a.x == b.x and a.y == b.y and a.w == b.w and a.h == b.h
end

local function target()
    local win = hs.window.focusedWindow()
    local app = win and win:application()
    if not app or not app:isFrontmost() then
        return
    end
    local screen, id = win:screen(), win:id()
    if not screen or not id then
        return
    end
    local frame = win:frame()
    local bounds = win:isFullScreen() and screen:fullFrame() or screen:frame()
    local visible = intersection(frame, bounds)
    if visible then
        return { id = id, frame = frame, visible = visible }
    end
end

local function cell_direction(index)
    return (index - 1) % 3 - 1, math.floor((index - 1) / 3) - 1
end

local function cell(rect, index)
    local dx, dy = cell_direction(index)
    local w, h = rect.w / 3, rect.h / 3
    return {
        x = rect.x + (dx + 1) * w,
        y = rect.y + (dy + 1) * h,
        w = w,
        h = h,
    }
end

local function clamp_offset(value, limit)
    return math.max(0, math.min(value, limit))
end

local function display_rect(rect, bounds)
    -- Enlarge the drawing, not the region the keys and pointer act on.
    local w = math.min(bounds.w, math.max(rect.w, 78))
    local h = math.min(bounds.h, math.max(rect.h, 72))
    return {
        x = clamp_offset(rect.x + (rect.w - w) / 2, bounds.w - w),
        y = clamp_offset(rect.y + (rect.h - h) / 2, bounds.h - h),
        w = w,
        h = h,
    }
end

local function center(rect)
    return { x = rect.x + rect.w / 2, y = rect.y + rect.h / 2 }
end

local function aim_point()
    return session.nudge_point or center(session.rect)
end

local function overlay_elements(rect, bounds, aim, nudging)
    local elements = {}
    local white = { white = 1 }
    local black = { white = 0 }
    local function box(frame, fill, stroke)
        elements[#elements + 1] = {
            type = "rectangle",
            action = stroke and (fill and "strokeAndFill" or "stroke") or "fill",
            frame = frame,
            fillColor = fill,
            strokeColor = stroke,
        }
    end

    local function arm(dx, dy, w, h)
        box({ x = aim.x + dx - 1, y = aim.y + dy - 1, w = w + 2, h = h + 2 }, black)
        box({ x = aim.x + dx, y = aim.y + dy, w = w, h = h }, white)
    end
    if nudging then
        arm(-8, -1, 16, 2)
        arm(-1, -8, 2, 16)
        return elements
    end

    local grid = display_rect(rect, bounds)
    box(grid, { red = 0.12, green = 0.34, blue = 0.65, alpha = 0.24 }, white)
    for index in ipairs(cell_keys) do
        box(cell(grid, index), nil, { white = 1, alpha = 0.5 })
    end
    if not same_frame(grid, rect) then
        box(rect, nil, white)
    end
    -- Leave room for the centered S without obscuring the real aim point.
    arm(-15, -1, 4, 2)
    arm(11, -1, 4, 2)
    arm(-1, -14, 2, 4)
    arm(-1, 10, 2, 4)
    for index, key in ipairs(cell_keys) do
        local area = cell(grid, index)
        local cx, cy = area.x + area.w / 2, area.y + area.h / 2
        box({ x = cx - 10, y = cy - 9, w = 20, h = 18 }, { white = 0, alpha = 0.85 })
        elements[#elements + 1] = {
            type = "text",
            text = key:upper(),
            textSize = 13,
            textColor = white,
            textAlignment = "center",
            frame = { x = cx - 10, y = cy - 8, w = 20, h = 16 },
        }
    end
    return elements
end

local function render()
    local elements = overlay_elements(
        session.rect,
        session.target.visible,
        aim_point(),
        session.nudge_point ~= nil
    )
    session.canvas:replaceElements(elements)
end

local function cancel()
    if not session then
        return
    end
    local closing = session
    session = nil
    closing.timer:stop()
    modal:exit()
    closing.canvas:delete()
end

local function validate_target()
    if not session then
        return false
    end
    local now, original = target(), session.target
    if
        now
        and now.id == original.id
        and same_frame(now.frame, original.frame)
        and same_frame(now.visible, original.visible)
    then
        return true
    end
    cancel()
    return false
end

local function refine(index)
    if not session or session.nudge_point or not validate_target() then
        return
    end
    local rect = session.rect
    local grid = display_rect(rect, session.target.visible)
    session.rect = cell(rect, index)
    if grid.w > rect.w or grid.h > rect.h then
        -- Take one last letter selection from the smallest labeled grid, then pan the aim freely.
        session.nudge_point = center(session.rect)
    end
    render()
end

local function nudge(dx, dy)
    if (dx == 0 and dy == 0) or not session or not session.nudge_point or not validate_target() then
        return
    end
    local aim, bounds = session.nudge_point, session.target.visible
    local x = clamp_offset(aim.x + dx, bounds.w - 1)
    local y = clamp_offset(aim.y + dy, bounds.h - 1)
    if x ~= aim.x or y ~= aim.y then
        aim.x, aim.y = x, y
        render()
    end
end

local function finish(click)
    if not validate_target() then
        return
    end
    local aim, origin = aim_point(), session.target.visible
    local point = { x = origin.x + aim.x, y = origin.y + aim.y }
    cancel()
    if click then
        hs.eventtap.leftClick(point)
    else
        hs.mouse.absolutePosition(point)
        -- A warp alone may not notify the app to update hover UI.
        local event = hs.eventtap.event
        event.newMouseEvent(event.types.mouseMoved, point):post()
    end
end

local function start()
    local focused = target()
    if not focused then
        return
    end
    local canvas = hs.canvas.new(focused.visible)
    if not canvas then
        return
    end
    canvas:level(hs.canvas.windowLevels.overlay)
    canvas:behaviorAsLabels({ "moveToActiveSpace", "fullScreenAuxiliary" })
    canvas:clickActivating(false)
    session = {
        target = focused,
        canvas = canvas,
        rect = { x = 0, y = 0, w = focused.visible.w, h = focused.visible.h },
        timer = hs.timer.doEvery(0.15, validate_target),
    }
    render()
    canvas:show()
    modal:enter()
end

function M.bind(mods, key)
    M.shutdown()
    toggle = hs.hotkey.bind(mods, key, function()
        if session then
            cancel()
        else
            start()
        end
    end)
    if not toggle then
        return
    end
    modal = hs.hotkey.modal.new()
    for index, key in ipairs(cell_keys) do
        local dx, dy = cell_direction(index)
        local function step()
            nudge(dx, dy)
        end
        local function fast_step()
            nudge(dx * 10, dy * 10)
        end
        modal:bind({}, key, function()
            if session and session.nudge_point then
                step()
            else
                refine(index)
            end
        end, nil, step)
        modal:bind({ "shift" }, key, fast_step, nil, fast_step)
    end
    modal:bind({}, "escape", cancel)
    modal:bind({}, "return", function()
        finish(true)
    end)
    modal:bind({}, "space", function()
        finish(false)
    end)
end

function M.shutdown()
    cancel()
    if modal then
        modal:delete()
        modal = nil
    end
    if toggle then
        toggle:delete()
        toggle = nil
    end
end

return M
