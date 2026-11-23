local M = {}

function M.run(path)
    local keys, trigger, tick, canvas_frame, display, click, move, hover, labels, label_frames
    local active, showing, polling, frontmost = false, false, false, true
    local renders = 0
    local repeats
    local id = 42
    local window_frame = { x = -1000, y = 10, w = 1000, h = 810 }
    local screen_frame = { x = -900, y = 10, w = 900, h = 900 }
    local canvas = {
        level = function() end,
        behaviorAsLabels = function() end,
        clickActivating = function() end,
        replaceElements = function(_, elements)
            renders = renders + 1
            display = elements[1].frame
            labels, label_frames = {}, {}
            for _, element in ipairs(elements) do
                if element.type == "text" then
                    label_frames[#label_frames + 1] = element.frame
                    labels[#labels + 1] = element.text
                end
            end
        end,
        show = function()
            showing = true
        end,
        delete = function()
            showing = false
        end,
    }
    local win = {
        id = function()
            return id
        end,
        application = function()
            return {
                isFrontmost = function()
                    return frontmost
                end,
            }
        end,
        frame = function()
            return window_frame
        end,
        isFullScreen = function()
            return false
        end,
        screen = function()
            return {
                frame = function()
                    return screen_frame
                end,
            }
        end,
    }
    local function assert_closed()
        assert(
            not active and not showing and not polling,
            "grid must release its keys, canvas, and timer"
        )
    end
    local fake_hs = {
        window = {
            focusedWindow = function()
                return win
            end,
        },
        canvas = {
            windowLevels = { overlay = 1 },
            new = function(frame)
                canvas_frame = frame
                return canvas
            end,
        },
        hotkey = {
            bind = function(_, _, fn)
                trigger = fn
                return {
                    delete = function()
                        trigger = nil
                    end,
                }
            end,
            modal = {
                new = function()
                    keys, repeats = {}, {}
                    return {
                        bind = function(_, mods, key, fn, _, repeat_fn)
                            local chord = mods[1] and mods[1] .. "+" .. key or key
                            keys[chord], repeats[chord] = fn, repeat_fn
                        end,
                        enter = function()
                            active = true
                        end,
                        exit = function()
                            active = false
                        end,
                        delete = function()
                            keys = nil
                        end,
                    }
                end,
            },
        },
        timer = {
            doEvery = function(_, fn)
                tick, polling = fn, true
                return {
                    stop = function()
                        polling = false
                    end,
                }
            end,
        },
        mouse = {
            absolutePosition = function(point)
                assert_closed()
                move = point
            end,
        },
        eventtap = {
            leftClick = function(point)
                assert_closed()
                click = point
            end,
            event = {
                types = { mouseMoved = 1 },
                newMouseEvent = function(kind, point)
                    assert(kind == 1)
                    return {
                        post = function()
                            hover = point
                        end,
                    }
                end,
            },
        },
    }
    path = path or hs.configdir .. "/modules/mouse_grid.lua"
    local env = setmetatable({ hs = fake_hs }, { __index = _G })
    local load_module = assert(loadfile(path, "t", env))
    if setfenv then -- Also runnable with LuaJIT outside Hammerspoon.
        setfenv(load_module, env)
    end
    local grid = load_module()
    grid.bind({ "cmd", "ctrl" }, "g")

    local function assert_label_centers()
        assert(table.concat(labels) == "QWEASDZXC", "display letters in grid order")
        for index, frame in ipairs(label_frames) do
            local col, row = (index - 1) % 3, math.floor((index - 1) / 3)
            assert(
                math.abs(frame.x + frame.w / 2 - (display.x + (col + 0.5) * display.w / 3)) < 0.001
            )
            assert(
                math.abs(frame.y + frame.h / 2 - (display.y + (row + 0.5) * display.h / 3)) < 0.001
            )
        end
    end

    trigger()
    assert(active and showing and polling)
    assert(canvas_frame.x == -900 and canvas_frame.w == 900, "clip to the current display")
    assert_label_centers()
    assert(not keys.delete, "Backspace is not a grid command")
    keys.z()
    keys.c()
    assert(display.x == 200 and display.y == 720, "repeated keys refine the current cell")
    keys["return"]()
    assert(
        click.x == -650 and click.y == 775,
        "click the refined cell's center in screen coordinates"
    )

    click = nil
    trigger()
    keys.e()
    keys.space()
    assert(
        not click and move.x == -150 and move.y == 145 and hover == move,
        "move and deliver hover without clicking"
    )

    trigger()
    keys.s()
    keys.s()
    keys.s()
    assert(display.w == 78 and display.h == 72, "enlarge the small grid itself")
    assert(
        display.x + display.w / 2 == 450 and display.y + display.h / 2 == 405,
        "center it over the selection"
    )
    assert_label_centers()
    keys.c()
    keys["return"]()
    assert(
        math.abs(click.x - (-450 + 100 / 9)) < 0.001 and click.y == 425,
        "refine the real region, not the drawing"
    )
    click = nil

    trigger()
    for _ = 1, 3 do
        keys.x()
    end
    assert_label_centers()
    local grid_renders = renders
    repeats.x()
    keys["shift+x"]()
    assert(renders == grid_renders, "held or shifted letters do not zoom the labeled grid")
    assert(not keys.right, "arrows are not grid bindings")
    keys.x()
    assert(#labels == 0, "the final letter switches to a crosshair")
    local final_renders = renders
    keys.s()
    repeats.s()
    assert(renders == final_renders, "the center key leaves the crosshair in place")
    keys.x()
    keys.e()
    keys.d()
    for _ = 1, 20 do
        repeats.d()
    end
    keys["shift+a"]()
    keys.w()
    repeats["shift+w"]()
    assert(active and showing and #labels == 0, "movement does not reopen the labeled grid")
    keys["return"]()
    assert(
        math.abs(click.x + 438) < 0.001 and math.abs(click.y - 804) < 0.001,
        string.format(
            "nudge beyond the final cell and click there (got %.3f, %.3f)",
            click.x,
            click.y
        )
    )
    click = nil

    trigger()
    for _ = 1, 4 do
        keys.z()
    end
    for _ = 1, 100 do
        repeats["shift+z"]()
    end
    local edge_renders = renders
    keys.z()
    assert(renders == edge_renders, "nudging at a window edge does not redraw")
    keys.space()
    assert(
        move.x == -900 and move.y == 819 and hover == move,
        "stop nudging at the display-clipped window edge"
    )

    trigger()
    assert(
        display.w == canvas_frame.w and display.h == canvas_frame.h,
        "reopen at the full window after nudging"
    )
    assert_label_centers()
    keys.escape()
    assert_closed()

    trigger()
    frontmost = false
    tick()
    assert_closed()
    trigger()
    assert_closed()
    frontmost = true

    trigger()
    id = id + 1
    keys["return"]()
    assert_closed()
    assert(not click, "never click after focus changes, even between timer ticks")

    trigger()
    window_frame = { x = -1000, y = 10, w = 950, h = 810 }
    keys["return"]()
    assert_closed()
    assert(not click, "never click after a resize")

    trigger()
    trigger()
    assert_closed()
    trigger()
    grid.shutdown()
    assert_closed()
    assert(not trigger and not keys, "shutdown unbinds both the entry shortcut and the modal")
    print("Mouse grid tests passed")
    return true
end

return M
