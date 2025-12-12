local obj = {}

function obj:get_asset(filename)
    return hs.image.imageFromPath(hs.configdir .. "/assets/" .. filename)
end

-- icons were sourced from heroicons.dev and converted to PNGs using
-- `svgexport` (eg. svgexport assets/ban.svg assets/ban.png 50:50)
obj.assets = {
    logo = obj:get_asset("logo.png"),
    check = obj:get_asset("heroicons-mini/check-circle.png"),
    x = obj:get_asset("heroicons-mini/x-circle.png"),
    bolt = obj:get_asset("heroicons-mini/bolt.png"),
    bolt_slash = obj:get_asset("heroicons-mini/bolt-slash.png"),
}

obj.palette = {
    white = "#FFFFFF",
    black = "#121317",
    warn = "#9E9C41",
    success = "#6A8E23",
    error = "#B71C1C",
}

obj.styles = {
    info = {
        fillColor = { hex = obj.palette.black },
        textColor = { hex = obj.palette.white, alpha = 1.00 },
        strokeColor = { hex = obj.palette.white, alpha = 0.75 },
        strokeWidth = 1,
        radius = 0,
        padding = 16,
    },
    success = {
        fillColor = { hex = obj.palette.black },
        textColor = { hex = obj.palette.success, alpha = 1.00 },
        strokeColor = { hex = obj.palette.success, alpha = 0.75 },
        strokeWidth = 1,
        radius = 0,
        padding = 16,
    },
    warn = {
        fillColor = { hex = obj.palette.black },
        textColor = { hex = obj.palette.warn, alpha = 1.00 },
        strokeColor = { hex = obj.palette.warn, alpha = 0.75 },
        strokeWidth = 1,
        radius = 0,
        padding = 16,
    },
    error = {
        fillColor = { hex = obj.palette.black },
        textColor = { hex = obj.palette.error, alpha = 1.00 },
        strokeColor = { hex = obj.palette.error, alpha = 0.75 },
        strokeWidth = 1,
        radius = 0,
        padding = 16,
    },
}

string.rpad = function(str, len)
    return str .. string.rep(" ", len - #str)
end

string.lpad = function(str, len)
    return string.rep(" ", len - #str) .. str
end

--- Center text with whitespace resulting in a string with total length of `width`.
string.center = function(str, width)
    if #str > width then
        return str
    end
    local padchar = " "
    local diff = width - #str
    local padding_width = math.ceil(diff / 2)
    local padding = string.rep(padchar, padding_width)
    if diff % 2 ~= 0 then
        return padding .. str .. padding
    end
    -- additional space character on right when not evenly divisible
    return padding .. str .. padding .. padchar
end

--- Displays alert with `title` and pairs of `attributes`
---
--- Parameters:
--- * title     - Title message of alert
--- * attributes - Key-value pairs of attributes to present in body of alert
--- * style     - Style object or style name (info, success, warn, error)
--- * logo      - Image asset (optional)
--- * minimum_text_width - Minimum text width for centering (optional)
function obj:show(title, attributes, style, logo, minimum_text_width)
    -- Determine style name for alerts
    local style_name = "info"
    if type(style) == "string" then
        style_name = style
    elseif style == obj.styles.success then
        style_name = "success"
    elseif style == obj.styles.warn then
        style_name = "warn"
    elseif style == obj.styles.error then
        style_name = "error"
    end

    -- Use modern canvas-based alert system
    return obj:show_modern(title, attributes, style_name, logo)
end

function obj:show_centered(title, style, logo, width)
    local text = string.center(title, width)
    obj:show(text, nil, style, logo)
end

function obj:info(msg)
    return obj:show_modern(msg, nil, "info")
end

function obj:success(msg)
    return obj:show_modern(msg, nil, "success")
end

function obj:warn(msg)
    return obj:show_modern(msg, nil, "warn")
end

function obj:error(msg)
    return obj:show_modern(msg, nil, "error")
end

--- Modern canvas-based alert system
obj.alert = {
    active_alerts = {},
    order = {},
    display_duration = 2.0,
    margin = 24,
    spacing = 12,
    width = 360,
    padding = 14,
    line_height = 16,
    detail_line_height = 8,
    detail_spacing = 8,
    font = ".AppleSystemUIFont",
    title_size = 14,
    detail_size = 12,
    icon_size = 22,
    icon_spacing = 10,
    text_vertical_offset = -1,
    animation_duration = 0.18,
    animation_steps = 12,
    styles = {
        info = {
            fillColor = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
            strokeColor = { red = 0.4, green = 0.6, blue = 1, alpha = 1 },
            textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            secondaryTextColor = { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 },
        },
        success = {
            fillColor = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
            strokeColor = { red = 0.4, green = 0.8, blue = 0.4, alpha = 1 },
            textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            secondaryTextColor = { red = 0.8, green = 0.93, blue = 0.8, alpha = 1 },
        },
        warn = {
            fillColor = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
            strokeColor = { red = 1, green = 0.8, blue = 0.2, alpha = 1 },
            textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            secondaryTextColor = { red = 1, green = 0.9, blue = 0.6, alpha = 1 },
        },
        error = {
            fillColor = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
            strokeColor = { red = 1, green = 0.4, blue = 0.4, alpha = 1 },
            textColor = { red = 1, green = 1, blue = 1, alpha = 1 },
            secondaryTextColor = { red = 1, green = 0.7, blue = 0.7, alpha = 1 },
        },
    },
}

local function get_alert_style(style_name)
    return obj.alert.styles[style_name] or obj.alert.styles.info
end

local function format_attributes(attributes)
    if not attributes then
        return {}
    end

    local lines = {}
    for _, attribute in ipairs(attributes) do
        if type(attribute) == "table" then
            local name = attribute.name or ""
            local value = attribute.value or ""
            if name ~= "" and value ~= "" then
                table.insert(lines, string.format("%s: %s", name, value))
            elseif name ~= "" then
                table.insert(lines, name)
            elseif value ~= "" then
                table.insert(lines, value)
            end
        elseif attribute ~= nil then
            table.insert(lines, tostring(attribute))
        end
    end

    return lines
end

local function calculate_alert_height(attributes)
    local attribute_count = #attributes
    local height = (obj.alert.padding * 2) + obj.alert.line_height

    if attribute_count > 0 then
        height = height + obj.alert.detail_spacing + (attribute_count * obj.alert.detail_line_height)
    end

    return height
end

local function remove_from_order(alert_id)
    for index, id in ipairs(obj.alert.order) do
        if id == alert_id then
            table.remove(obj.alert.order, index)
            return
        end
    end
end

function obj:_reflow_alerts()
    local screen = hs.screen.mainScreen()
    if not screen then
        return
    end

    local screen_frame = screen:frame()
    local x = screen_frame.x + (screen_frame.w - obj.alert.width) / 2

    local visible_alerts = {}

    for _, alert_id in ipairs(obj.alert.order) do
        local alert_data = obj.alert.active_alerts[alert_id]
        if alert_data and alert_data.canvas then
            table.insert(visible_alerts, alert_data)
        end
    end

    if #visible_alerts == 0 then
        return
    end

    table.sort(visible_alerts, function(a, b)
        return (a.start_time or 0) < (b.start_time or 0)
    end)

    local newest_alert = visible_alerts[#visible_alerts]
    local center_y = screen_frame.y + (screen_frame.h / 2)
    local newest_top = center_y - (newest_alert.height / 2)

    newest_alert.canvas:frame({
        x = x,
        y = newest_top,
        w = obj.alert.width,
        h = newest_alert.height,
    })

    local current_top = newest_top

    for index = #visible_alerts - 1, 1, -1 do
        local alert_data = visible_alerts[index]
        current_top = current_top - obj.alert.spacing - alert_data.height
        alert_data.canvas:frame({
            x = x,
            y = current_top,
            w = obj.alert.width,
            h = alert_data.height,
        })
    end

    local newest_index = #visible_alerts
    for index, alert_data in ipairs(visible_alerts) do
        local distance = newest_index - index
        local target_alpha = 1 - (distance * 0.25)
        target_alpha = math.max(0.35, math.min(1, target_alpha))
        obj:_animate_canvas_alpha(alert_data.canvas, target_alpha, obj.alert.animation_duration / 2)
    end
end

function obj:_animate_canvas_alpha(canvas, target_alpha, duration, on_complete)
    if not canvas then
        return
    end

    duration = duration or 0
    local current_alpha = canvas:alpha() or 1
    if duration <= 0 or obj.alert.animation_steps <= 0 then
        canvas:alpha(target_alpha)
        if on_complete then
            on_complete()
        end
        return
    end

    local step = 0
    local total_steps = obj.alert.animation_steps
    local alpha_delta = target_alpha - current_alpha
    local interval = duration / total_steps
    local animation_timer

    animation_timer = hs.timer.doEvery(interval, function()
        step = step + 1
        local progress = step / total_steps
        local eased_progress = progress * progress
        local alpha = current_alpha + (alpha_delta * eased_progress)
        canvas:alpha(alpha)

        if step >= total_steps then
            animation_timer:stop()
            canvas:alpha(target_alpha)
            if on_complete then
                on_complete()
            end
        end
    end)
end

--- Create and show modern canvas-based alert
function obj:show_modern(title, attributes, style_name, icon)
    local resolved_style = get_alert_style(style_name or "info")
    local formatted_attributes = format_attributes(attributes)
    local height = calculate_alert_height(formatted_attributes)

    local canvas = hs.canvas.new({ x = 0, y = 0, w = obj.alert.width, h = height })
    local alert_id = tostring(canvas)

    canvas[1] = {
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = 4, yRadius = 4 },
        fillColor = resolved_style.fillColor,
    }

    canvas[2] = {
        type = "rectangle",
        action = "stroke",
        roundedRectRadii = { xRadius = 4, yRadius = 4 },
        strokeColor = resolved_style.strokeColor,
        strokeWidth = 1,
    }

    local text_x = obj.alert.padding

    if icon then
        local vertical_space = height - (obj.alert.padding * 2)
        local icon_y = obj.alert.padding + math.max(0, (vertical_space - obj.alert.icon_size) / 2)

        canvas[#canvas + 1] = {
            type = "image",
            image = icon,
            frame = { x = text_x, y = icon_y, w = obj.alert.icon_size, h = obj.alert.icon_size },
            imageScaling = "scaleProportionally",
        }

        text_x = text_x + obj.alert.icon_size + obj.alert.icon_spacing
    end

    local title_width = obj.alert.width - text_x - obj.alert.padding

    local title_y = obj.alert.padding + (obj.alert.line_height - obj.alert.title_size) / 2 + obj.alert.text_vertical_offset

    canvas[#canvas + 1] = {
        type = "text",
        text = title,
        textFont = obj.alert.font,
        textSize = obj.alert.title_size,
        textColor = resolved_style.textColor,
        textAlignment = "left",
        frame = { x = text_x, y = title_y, w = title_width, h = obj.alert.line_height },
    }

    local current_y = title_y + obj.alert.line_height + obj.alert.detail_spacing
    for _, attribute_text in ipairs(formatted_attributes) do
        local attribute_y = current_y + (obj.alert.detail_line_height - obj.alert.detail_size) / 2 + obj.alert.text_vertical_offset
        canvas[#canvas + 1] = {
            type = "text",
            text = attribute_text,
            textFont = obj.alert.font,
            textSize = obj.alert.detail_size,
            textColor = resolved_style.secondaryTextColor or resolved_style.textColor,
            textAlignment = "left",
            frame = { x = text_x, y = attribute_y, w = title_width, h = obj.alert.detail_line_height },
        }
        current_y = current_y + obj.alert.detail_line_height
    end

    canvas:level(hs.canvas.windowLevels.overlay)
    canvas:alpha(1)

    local dismiss_timer = hs.timer.doAfter(obj.alert.display_duration, function()
        obj:dismiss_alert(alert_id)
    end)

    obj.alert.active_alerts[alert_id] = {
        canvas = canvas,
        timer = dismiss_timer,
        start_time = hs.timer.secondsSinceEpoch(),
        height = height,
    }
    table.insert(obj.alert.order, alert_id)

    obj:_reflow_alerts()
    canvas:show()

    return alert_id
end

--- Dismiss alert with animation
function obj:dismiss_alert(alert_id)
    local alert_data = obj.alert.active_alerts[alert_id]
    if not alert_data or not alert_data.canvas then
        return
    end

    if alert_data.timer then
        alert_data.timer:stop()
        alert_data.timer = nil
    end

    local canvas = alert_data.canvas

    obj.alert.active_alerts[alert_id] = nil
    remove_from_order(alert_id)
    obj:_reflow_alerts()

    obj:_animate_canvas_alpha(canvas, 0, obj.alert.animation_duration, function()
        canvas:hide()
        canvas:delete()
    end)
end

--- Dismiss all active alerts
function obj:dismiss_all_alerts()
    local active_ids = {}
    for alert_id, _ in pairs(obj.alert.active_alerts) do
        table.insert(active_ids, alert_id)
    end

    for _, alert_id in ipairs(active_ids) do
        obj:dismiss_alert(alert_id)
    end
end

--- Debug method to show active alerts
function obj:debug_active_alerts()
    print("=== DEBUG: Active Modern Alerts ===")
    local count = 0
    for alert_id, alert_data in pairs(obj.alert.active_alerts) do
        count = count + 1
        print("Alert " .. count .. ": ID=" .. alert_id)
        print("  Canvas exists: " .. tostring(alert_data.canvas ~= nil))
        print("  Timer exists: " .. tostring(alert_data.timer ~= nil))
        if alert_data.timer then
            print("  Timer running: " .. tostring(alert_data.timer:running()))
        end
        print("  Start time: " .. alert_data.start_time)
    end
    print("Total active alerts: " .. count)
    print("===================================")
end

-- Sleep for `ms` milliseconds.
--
-- http://lua-users.org/wiki/SleepFunction
function obj:sleep(ms)
    os.execute("sleep " .. tonumber(ms) / 1000)
end

function obj:led_blinker()
    for _ = 1, 10 do
        obj:sleep(100)
        hs.hid.led.set("caps", true)
        obj:sleep(100)
        hs.hid.led.set("caps", false)
    end
end

-- function obj.tty()
--     local handle, err = io.popen("tty")
--     local output = handle:read("*all")
--     handle:close()
--     return output
-- end

return obj
