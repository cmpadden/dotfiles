local glass_toast = require("modules.glass_toast")
local helpers = require("modules.helpers")

hs.hotkey.bind(HYPER, "0", function()
    hs.caffeinate.toggle("displayIdle")
    local enabled = hs.caffeinate.get("displayIdle")
    local title = enabled and "Caffeine Enabled" or "Caffeine Disabled"
    local style = enabled and helpers.styles.success or helpers.styles.error
    glass_toast:show(enabled and "enabled" or "disabled", title, function()
        helpers:show(title, nil, style)
    end)
end)
