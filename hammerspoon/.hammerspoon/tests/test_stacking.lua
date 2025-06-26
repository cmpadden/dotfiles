-- Alert stacking and positioning tests
-- Tests proper vertical stacking of multiple alerts

local helpers = require("modules.helpers")

local test = {}

function test.run()
    print("=== Running Alert Stacking Tests ===")

    -- Clear any existing alerts
    helpers:dismiss_all_alerts()

    print("Testing rapid alert creation for stacking...")

    -- Create multiple alerts rapidly to test stacking
    helpers:info("Stack Test 1 - Top Position")

    hs.timer.doAfter(0.1, function()
        helpers:success("Stack Test 2 - Should be below #1")
    end)

    hs.timer.doAfter(0.2, function()
        helpers:warn("Stack Test 3 - Should be below #2")
    end)

    hs.timer.doAfter(0.3, function()
        helpers:error("Stack Test 4 - Should be below #3")
    end)

    hs.timer.doAfter(0.4, function()
        helpers:show("Stack Test 5 - Bottom Alert", {
            { name = "Position", value = "Bottom of stack" },
            { name = "Spacing", value = "10px gap" },
            { name = "Overlap", value = "None" },
        }, "info")
    end)

    print("✓ Created 5 alerts with 0.1s intervals")
    print("✓ Should stack vertically without overlapping")
    print("✓ 10px spacing between each alert")

    -- Check stacking after creation
    hs.timer.doAfter(1, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end
        print("Active alerts after creation: " .. count)

        if count == 5 then
            print("✅ PASS: All 5 alerts created and stacked")
        else
            print("❌ FAIL: Expected 5 alerts, found " .. count)
        end
    end)

    -- Check auto-dismissal
    hs.timer.doAfter(5, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end

        if count == 0 then
            print("✅ PASS: All stacked alerts auto-dismissed")
        else
            print("❌ FAIL: " .. count .. " alerts still active after dismissal")
        end
    end)
end

function test.stress_test()
    print("=== Running Stacking Stress Test ===")

    helpers:dismiss_all_alerts()

    print("Creating 10 alerts rapidly...")

    for i = 1, 10 do
        hs.timer.doAfter(i * 0.05, function()
            local alert_type = { "info", "success", "warn", "error" }
            local type_index = ((i - 1) % 4) + 1
            helpers:show("Stress Test #" .. i, {
                { name = "Alert", value = "Number " .. i },
                { name = "Type", value = alert_type[type_index] },
            }, alert_type[type_index])
        end)
    end

    print("✓ Should create 10 stacked alerts")
    print("✓ All should auto-dismiss after 3 seconds")
end

return test
