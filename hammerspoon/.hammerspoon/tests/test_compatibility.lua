-- Backward compatibility tests
-- Tests that existing alert calls still work with modern system

local helpers = require("modules.helpers")

local test = {}

function test.run()
    print("=== Running Backward Compatibility Tests ===")

    helpers:dismiss_all_alerts()

    print("Testing existing API compatibility...")

    -- Test original show method with different parameter combinations

    -- 1. Basic title only (how init.lua calls it)
    helpers:show("Hammerspoon Loaded (Compatibility Test)", nil, nil, nil)

    hs.timer.doAfter(0.5, function()
        -- 2. With style object (how caffeine.lua calls it)
        helpers:show("Caffeine Enabled (Compatibility)", nil, helpers.styles.success)
    end)

    hs.timer.doAfter(1.0, function()
        helpers:show("Caffeine Disabled (Compatibility)", nil, helpers.styles.error)
    end)

    hs.timer.doAfter(1.5, function()
        -- 3. With attributes (like the commented watchers.lua usage)
        local test_attributes = {
            { name = "Original API", value = "Working" },
            { name = "Modern Backend", value = "Active" },
            { name = "Style Detection", value = "Automatic" },
        }
        helpers:show("Compatibility with Attributes", test_attributes, helpers.styles.warn)
    end)

    hs.timer.doAfter(2.0, function()
        -- 4. Test convenience methods (used throughout codebase)
        helpers:info("Info method compatibility")
    end)

    hs.timer.doAfter(2.5, function()
        helpers:success("Success method compatibility")
    end)

    hs.timer.doAfter(3.0, function()
        helpers:warn("Warning method compatibility")
    end)

    hs.timer.doAfter(3.5, function()
        helpers:error("Error method compatibility")
    end)

    print("✓ Testing all existing API patterns")
    print("✓ Should work exactly like before but with modern design")

    -- Verify all work
    hs.timer.doAfter(4, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end
        print("Total alerts created: " .. count)

        if count >= 7 then
            print("✅ PASS: All compatibility tests created alerts")
        else
            print("❌ FAIL: Some compatibility tests failed")
        end
    end)

    -- Check auto-dismissal
    hs.timer.doAfter(8, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end

        if count == 0 then
            print("✅ PASS: All compatibility alerts auto-dismissed")
        else
            print("❌ FAIL: " .. count .. " compatibility alerts remain")
        end
    end)
end

return test
