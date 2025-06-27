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
    -- TODO - light and dark mode variants depending on system setting
    -- warn = "#FFF59D",
    -- success = "#F6FCDF",
    -- error = "#FFCDD2",
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
    animation_duration = 0.3,
    display_duration = 3.0,
    margin = 20,
    min_width = 280,
    max_width = 420,
}

--- Calculate dynamic size based on content
local function calculate_alert_size(title, attributes)
    local font_size_title = 14
    local font_size_detail = 11
    local line_height = 1.4
    local padding = 12
    local attr_spacing = 8

    -- Rough character width estimation for SF Pro Display
    local char_width_title = font_size_title * 0.6
    local char_width_detail = font_size_detail * 0.55

    -- Calculate title dimensions
    local title_width = math.min(#title * char_width_title, obj.alert.max_width - (padding * 2))
    local title_lines = math.ceil((#title * char_width_title) / title_width)

    -- Calculate height
    local height = padding * 2 + (title_lines * font_size_title * line_height)

    -- Add attributes height if present
    if attributes then
        for i = 1, #attributes do
            local attr_text = attributes[i].name .. ": " .. attributes[i].value
            local attr_lines = math.ceil((#attr_text * char_width_detail) / title_width)
            height = height + (attr_lines * font_size_detail * line_height) + attr_spacing
        end
        height = height + attr_spacing -- Extra spacing after attributes
    end

    local width = math.max(title_width + (padding * 2), obj.alert.min_width)
    width = math.min(width, obj.alert.max_width)

    return width, height
end

--- Position alert on screen with proper spacing
local function calculate_alert_position(width, height)
    local screen = hs.screen.mainScreen()
    local screen_frame = screen:frame()

    -- Position in center of screen
    local x = screen_frame.x + (screen_frame.w - width) / 2
    local y = screen_frame.y + (screen_frame.h - height) / 2

    -- Stack multiple alerts vertically by finding the lowest bottom edge
    local lowest_bottom = y
    for alert_id, alert_data in pairs(obj.alert.active_alerts) do
        if alert_data.canvas then
            local existing_frame = alert_data.canvas:frame()
            if existing_frame then
                -- Use final position if alert is still animating in, otherwise use current position
                local alert_y = alert_data.final_y or existing_frame.y
                local alert_height = existing_frame.h

                -- Since all alerts are centered horizontally, they will always overlap
                -- Stack them vertically with a 10px gap
                local bottom_edge = alert_y + alert_height + 10
                lowest_bottom = math.max(lowest_bottom, bottom_edge)
            end
        end
    end

    return x, lowest_bottom
end

--- Create modern gradient background styles
local function get_modern_style(style_type)
    local base_styles = {
        info = {
            background_start = { red = 0.15, green = 0.15, blue = 0.15, alpha = 0.95 },
            background_end = { red = 0.12, green = 0.12, blue = 0.12, alpha = 0.95 },
            text_color = { red = 1, green = 1, blue = 1, alpha = 1 },
            accent_color = { red = 0.4, green = 0.6, blue = 1, alpha = 1 },
        },
        success = {
            background_start = { red = 0.12, green = 0.2, blue = 0.15, alpha = 0.95 },
            background_end = { red = 0.08, green = 0.15, blue = 0.1, alpha = 0.95 },
            text_color = { red = 1, green = 1, blue = 1, alpha = 1 },
            accent_color = { red = 0.4, green = 0.8, blue = 0.4, alpha = 1 },
        },
        warn = {
            background_start = { red = 0.25, green = 0.2, blue = 0.08, alpha = 0.95 },
            background_end = { red = 0.2, green = 0.15, blue = 0.05, alpha = 0.95 },
            text_color = { red = 1, green = 1, blue = 1, alpha = 1 },
            accent_color = { red = 1, green = 0.8, blue = 0.2, alpha = 1 },
        },
        error = {
            background_start = { red = 0.25, green = 0.1, blue = 0.1, alpha = 0.95 },
            background_end = { red = 0.2, green = 0.05, blue = 0.05, alpha = 0.95 },
            text_color = { red = 1, green = 1, blue = 1, alpha = 1 },
            accent_color = { red = 1, green = 0.4, blue = 0.4, alpha = 1 },
        },
    }
    return base_styles[style_type] or base_styles.info
end

--- Create and show modern canvas-based alert
function obj:show_modern(title, attributes, style_name, icon)
    style_name = style_name or "info"
    local style = get_modern_style(style_name)

    -- Calculate dimensions and position
    local width, height = calculate_alert_size(title, attributes)
    local x, y = calculate_alert_position(width, height)

    -- Create canvas
    local canvas = hs.canvas.new({ x = x, y = y - height, w = width, h = height })
    local alert_id = tostring(canvas)

    -- Background with gradient
    canvas[1] = {
        type = "rectangle",
        action = "fill",
        roundedRectRadii = { xRadius = 6, yRadius = 6 },
        fillGradientColors = { style.background_start, style.background_end },
        fillGradient = "linear",
        fillGradientAngle = 135,
    }

    -- Accent border
    canvas[2] = {
        type = "rectangle",
        action = "stroke",
        roundedRectRadii = { xRadius = 6, yRadius = 6 },
        strokeColor = style.accent_color,
        strokeWidth = 1,
        frame = { x = 0.5, y = 0.5, w = width - 1, h = height - 1 },
    }

    -- Title text - center vertically in available space
    local title_height = 20 -- Reduced from 22 due to smaller font
    local title_y
    if attributes then
        -- For alerts with attributes, position title near top but with some padding
        title_y = 14 -- Move slightly lower
    else
        -- For simple alerts, center the title vertically with slight downward adjustment
        title_y = (height - title_height) / 2 + 2 -- Move 2px lower
    end

    canvas[3] = {
        type = "text",
        text = title,
        textFont = ".AppleSystemUIFont",
        textSize = 14,
        textColor = style.text_color,
        textAlignment = "left",
        frame = { x = 12, y = title_y, w = width - 24, h = title_height },
    }

    -- Attributes
    local attr_y = title_y + title_height + 8
    if attributes then
        for i = 1, #attributes do
            local attr_text = attributes[i].name .. ": " .. attributes[i].value
            canvas[3 + i] = {
                type = "text",
                text = attr_text,
                textFont = ".AppleSystemUIFont",
                textSize = 11,
                textColor = { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 },
                textAlignment = "left",
                frame = { x = 12, y = attr_y, w = width - 24, h = 16 },
            }
            attr_y = attr_y + 20
        end
    end

    -- Store alert data with final position for stacking calculation
    obj.alert.active_alerts[alert_id] = {
        canvas = canvas,
        timer = nil,
        start_time = hs.timer.secondsSinceEpoch(),
        final_y = y, -- Store final Y position for proper stacking
    }

    -- Store alert in active alerts table

    -- Animate in with subtle slide and fade
    local final_y = y
    local start_y = y - 30 -- Start just 30px above final position
    local animation_steps = 15
    local step_duration = obj.alert.animation_duration / animation_steps
    local step = 0

    -- Set initial position and opacity
    canvas:frame({ x = x, y = start_y, w = width, h = height })
    canvas:alpha(0)
    canvas:show()

    -- Declare timer variable outside callback for proper scope
    local animate_in_timer
    animate_in_timer = hs.timer.doEvery(step_duration, function()
        step = step + 1
        local progress = step / animation_steps
        -- Ease out animation
        local eased_progress = 1 - math.pow(1 - progress, 3)
        local current_y = start_y + (final_y - start_y) * eased_progress
        local current_alpha = eased_progress

        local frame = canvas:frame()
        frame.y = current_y
        canvas:frame(frame)
        canvas:alpha(current_alpha)

        if step >= animation_steps then
            animate_in_timer:stop()

            -- Set up auto-dismiss timer
            local dismiss_timer = hs.timer.doAfter(obj.alert.display_duration, function()
                obj:dismiss_alert(alert_id)
            end)

            -- Store the timer in the alert data
            if obj.alert.active_alerts[alert_id] then
                obj.alert.active_alerts[alert_id].timer = dismiss_timer
            else
                dismiss_timer:stop()
            end
        end
    end)
end

--- Dismiss alert with animation
function obj:dismiss_alert(alert_id)
    local alert_data = obj.alert.active_alerts[alert_id]
    if not alert_data or not alert_data.canvas then
        return
    end

    local canvas = alert_data.canvas
    local start_frame = canvas:frame()
    local animation_steps = 15
    local step_duration = obj.alert.animation_duration / animation_steps
    local step = 0

    -- Stop any existing timer
    if alert_data.timer then
        alert_data.timer:stop()
        alert_data.timer = nil
    end

    -- Fade out with subtle slide up
    local start_y = start_frame.y
    local target_y = start_y - 20 -- Move just 20px up

    -- Declare timer variable outside callback for proper scope
    local animate_out_timer
    animate_out_timer = hs.timer.doEvery(step_duration, function()
        step = step + 1
        local progress = step / animation_steps
        -- Ease in animation for dismiss
        local eased_progress = math.pow(progress, 2)
        local current_y = start_y + (target_y - start_y) * eased_progress
        local current_alpha = 1 - eased_progress

        -- Move canvas upward and fade out
        local frame = canvas:frame()
        frame.y = current_y
        canvas:frame(frame)
        canvas:alpha(current_alpha)

        if step >= animation_steps then
            animate_out_timer:stop()
            canvas:delete()
            obj.alert.active_alerts[alert_id] = nil
        end
    end)
end

--- Dismiss all active alerts
function obj:dismiss_all_alerts()
    for alert_id, _ in pairs(obj.alert.active_alerts) do
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
