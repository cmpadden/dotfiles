-- Exercise the HUD with a fake clock and canvas (no UI or caffeine changes).
local test = {}

function test.run()
    local now, reduce_motion = 0, false
    local timers, canvases = {}, {}
    local function schedule(delay, callback, repeats)
        local timer = { due = now + delay, active = true }
        function timer:stop()
            self.active = false
        end
        function timer:fire()
            self.active = repeats
            self.due = self.due + delay
            callback()
        end
        table.insert(timers, timer)
        return timer
    end

    local function advance(seconds)
        local target = now + seconds
        while true do
            local next_timer
            for _, timer in ipairs(timers) do
                if
                    timer.active
                    and timer.due <= target
                    and (not next_timer or timer.due < next_timer.due)
                then
                    next_timer = timer
                end
            end
            if not next_timer then
                break
            end
            now = next_timer.due
            next_timer:fire()
        end
        now = target
    end

    local env = setmetatable({
        hs = {
            execute = function()
                return reduce_motion and "1\n" or "0\n"
            end,
            timer = {
                absoluteTime = function()
                    return now * 1e9
                end,
                doEvery = function(delay, callback)
                    return schedule(delay, callback, true)
                end,
                doAfter = function(delay, callback)
                    return schedule(delay, callback, false)
                end,
            },
            screen = {
                mainScreen = function()
                    return {
                        frame = function()
                            return { x = 0, y = 24, w = 1000, h = 800 }
                        end,
                    }
                end,
            },
            drawing = {
                getTextDrawingSize = function()
                    return { h = 16 }
                end,
            },
            canvas = {
                windowLevels = { overlay = 1 },
                new = function(frame)
                    local canvas = {}
                    function canvas:appendElements(...)
                        for i, element in ipairs({ ... }) do
                            self[i] = element
                        end
                    end
                    function canvas:frame()
                        return frame
                    end
                    function canvas:alpha(value)
                        self.opacity = value
                    end
                    function canvas:level()
                        return self
                    end
                    function canvas:show() end
                    function canvas:delete()
                        self.deleted = true
                    end
                    table.insert(canvases, canvas)
                    return canvas
                end,
            },
        },
    }, { __index = _G })
    local island = assert(loadfile(hs.configdir .. "/modules/island_hud.lua", "t", env))()
    local function center(frame)
        return frame.y + frame.h / 2
    end

    island.show("Reloaded", "top")
    local canvas = canvases[1]
    island.show("Caffeine Enabled", "top")
    assert(canvas[3].text == "Caffeine Enabled", "an invisible label should update immediately")
    advance(0.17)
    local tip = canvas[1].coordinates[4].y
    assert(
        canvas[1].action == "fill" and tip == center(canvas[2].frame),
        "tether must overlap during pinch-off"
    )
    advance(0.03)
    assert(
        canvas[1].action == "skip" and center(canvas[2].frame) < 40,
        "capsule should settle after detaching"
    )
    advance(0.93)
    assert(canvas[2].frame.w == 200 and center(canvas[2].frame) == 40)

    island.show("Reloaded", "top")
    advance(0.02)
    assert(
        canvas[3].text == "Caffeine Enabled" and canvas[3].textColor.alpha < 1,
        "old label should fade out"
    )
    island.show("Caffeine Enabled", "top")
    island.show("Caffeine Disabled", "top")
    advance(0.05)
    assert(canvas[3].text == "Caffeine Disabled", "only the latest pending label should appear")
    advance(0.12)
    assert(canvas[3].textColor.alpha == 1 and #canvases == 1)
    advance(0.4)
    assert(
        canvas.opacity == 1 and canvas[2].frame.w == 200,
        "refresh should extend the hold without replaying the opening"
    )

    advance(0.71)
    local rising_center = center(canvas[2].frame)
    assert(rising_center < 40 and canvas.opacity == 1, "exit should rise without fading")
    advance(0.06)
    assert(center(canvas[2].frame) < rising_center and canvas.opacity == 1)
    assert(
        canvas[1].action == "fill" and canvas[1].coordinates[4].y == center(canvas[2].frame),
        "the tether should reconnect as the capsule rises"
    )
    island.show("Caffeine Enabled", "top")
    advance(0.25)
    assert(
        #canvases == 1 and canvas.opacity == 1 and canvas[2].frame.w == 200,
        "a new message should reverse the exit on the same canvas"
    )
    advance(1.5)
    assert(canvas.deleted, "the refreshed canvas should still dismiss")
    assert(
        canvas[2].frame.y + canvas[2].frame.h <= 0 and canvas[1].action == "skip",
        "exit should fully retract past the top edge"
    )

    reduce_motion = true
    island.show("Reloaded", "top")
    canvas = canvases[2]
    advance(0.08)
    assert(canvas.opacity > 0 and canvas.opacity < 1, "Reduce Motion should fade in")
    assert(
        canvas[1].action == "skip" and canvas[2].frame.w == 200 and center(canvas[2].frame) == 40
    )
    advance(1.34)
    assert(canvas.opacity > 0 and canvas.opacity < 1, "Reduce Motion should fade out")
    assert(
        canvas[1].action == "skip" and canvas[2].frame.w == 200 and center(canvas[2].frame) == 40
    )
    island.show("Caffeine Enabled", "top")
    island.dismiss()
    advance(2)
    assert(canvas.deleted, "dismiss should cancel both animation timers")
    print("PASS: island tether, exit, rapid updates, hold extension, and Reduce Motion")
end

return test
