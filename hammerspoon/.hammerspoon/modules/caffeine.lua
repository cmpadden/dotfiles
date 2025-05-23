local helpers = require("modules.helpers")

hs.hotkey.bind(HYPER, "0", function()
    hs.caffeinate.toggle("displayIdle")
    if hs.caffeinate.get("displayIdle") then
        -- helpers:show("Caffeine Enabled", nil, helpers.styles.success, helpers.assets.bolt)
        helpers:show("Caffeine Enabled", nil, helpers.styles.success)
    else
        -- helpers:show("Caffeine Disabled", nil, helpers.styles.error, helpers.assets.bolt_slash)
        helpers:show("Caffeine Disabled", nil, helpers.styles.error)
    end
end)
