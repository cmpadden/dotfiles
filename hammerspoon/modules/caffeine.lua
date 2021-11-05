--------------------------------------------------------------------------------
--                              Caffeine Toggle                               --
--------------------------------------------------------------------------------

-- For a menu-bar version of caffeine, see:
-- https://gist.github.com/heptal/50998f66de5aba955c00

local helpers = require("modules.helpers")

hs.hotkey.bind(HYPER, "0", function()
    hs.caffeinate.toggle("displayIdle")
    if hs.caffeinate.get("displayIdle") then
        helpers:show("Caffeine Enabled", nil, helpers.styles.success, helpers.assets.check)
    else
        helpers:show("Caffeine Disabled", nil, helpers.styles.error, helpers.assets.ban)
    end
end)
