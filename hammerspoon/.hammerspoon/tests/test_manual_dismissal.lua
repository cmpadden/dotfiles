-- Manual dismissal and cleanup tests
-- Tests manual dismissal functionality and cleanup

local helpers = require("modules.helpers")

local test = {}

function test.run()
    print("=== Running Manual Dismissal Tests ===")

    -- Clear any existing alerts
    helpers:dismiss_all_alerts()

    print("Testing manual dismissal functionality...")

    -- Create some alerts
    helpers:info("Manual Dismiss Test 1")
    helpers:success("Manual Dismiss Test 2")
    helpers:warn("Manual Dismiss Test 3")

    print("Created 3 alerts for manual dismissal test")

    -- Check creation
    hs.timer.doAfter(0.5, function()
        local count = 0
        for _ in pairs(helpers.alert.active_alerts) do
            count = count + 1
        end
        print("Active alerts before dismissal: " .. count)

        if count == 3 then
            print("✅ PASS: All 3 alerts created successfully")

            -- Manually dismiss all
            print("Manually dismissing all alerts...")
            helpers:dismiss_all_alerts()

            -- Check dismissal worked
            hs.timer.doAfter(1, function()
                local count_after = 0
                for _ in pairs(helpers.alert.active_alerts) do
                    count_after = count_after + 1
                end

                if count_after == 0 then
                    print("✅ PASS: Manual dismissal successful")
                else
                    print("❌ FAIL: " .. count_after .. " alerts remain after manual dismissal")
                end
            end)
        else
            print("❌ FAIL: Expected 3 alerts, found " .. count)
        end
    end)
end

function test.debug_test()
    print("=== Running Debug Information Test ===")

    helpers:dismiss_all_alerts()

    -- Create a few alerts
    helpers:info("Debug Test Alert 1")
    helpers:error("Debug Test Alert 2")

    hs.timer.doAfter(0.5, function()
        print("Showing debug information:")
        helpers:debug_active_alerts()
    end)

    hs.timer.doAfter(4, function()
        print("Debug info after auto-dismissal:")
        helpers:debug_active_alerts()
    end)
end

return test
