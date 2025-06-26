-- Basic alert functionality tests
-- Tests individual alert types and basic functionality

local helpers = require("modules.helpers")

local test = {}

function test.run()
    print("=== Running Basic Alert Tests ===")

    -- Clear any existing alerts
    helpers:dismiss_all_alerts()

    print("Testing individual alert types...")

    -- Test each alert type with delays
    helpers:info("Info Alert Test")

    hs.timer.doAfter(0.5, function()
        helpers:success("Success Alert Test")
    end)

    hs.timer.doAfter(1.0, function()
        helpers:warn("Warning Alert Test")
    end)

    hs.timer.doAfter(1.5, function()
        helpers:error("Error Alert Test")
    end)

    -- Test alert with attributes
    hs.timer.doAfter(2.0, function()
        helpers:show("Alert with Details", {
            { name = "Test Type", value = "Basic Functionality" },
            { name = "Font", value = "System UI Font" },
            { name = "Animation", value = "Slide In/Out" },
        }, "info")
    end)

    print("✓ Created 5 different alert types")
    print("✓ Each should auto-dismiss after 3 seconds")
    print("✓ Watch for proper fonts and animations")

    -- Verification timer
    hs.timer.doAfter(4, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end

        if count == 0 then
            print("✅ PASS: All alerts auto-dismissed successfully")
        else
            print("❌ FAIL: " .. count .. " alerts still active")
        end
    end)
end

return test
