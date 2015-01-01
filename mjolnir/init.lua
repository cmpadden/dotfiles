local application = require "mjolnir.application"
local hotkey = require "mjolnir.hotkey"
local window = require "mjolnir.window"
local fnutils = require "mjolnir.fnutils"
local screen = require "mjolnir.screen"
local transform = require "mjolnir.sk.transform"
local grid = require "mjolnir.bg.grid"
local alert = require "mjolnir.alert"
 
local mash = {"cmd"}
local shiftmash = {"shift", "cmd"}

-- some global constants

-------------
-- WINDOWS --
-------------

local animation_time = 0.075
 
-- move window to left and resize to half-screen
hotkey.bind(mash, "a", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = 0
    frame.y = 0
    frame.w = sframe.w / 2.0
    frame.h = sframe.h
    transform:setframe(win, frame, animation_time)
end)
 
 -- move window to right and resize to half-screen
hotkey.bind(mash, "d", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = sframe.w / 2.0
    frame.y = 0
    frame.w = sframe.w / 2.0
    frame.h = sframe.h
    transform:setframe(win, frame, animation_time)
end)
 
-- move window to top and resize to half-screen
hotkey.bind(mash, "w", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = 0
    frame.y = 0
    frame.w = sframe.w
    frame.h = sframe.h / 2.0
    transform:setframe(win, frame, animation_time)
end)
 
-- move window to bottom and resize to half-screen
hotkey.bind(mash, "s", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = 0
    frame.y = sframe.h / 2.0
    frame.w = sframe.w
    frame.h = sframe.h / 2.0
    transform:setframe(win, frame, animation_time)
end)
 
-- move window to left and resize to full-screen
hotkey.bind(mash, "f", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = 0
    frame.y = 0
    frame.w = sframe.w
    frame.h = sframe.h
    transform:setframe(win, frame, animation_time)
end)
 
-- move window to center and resize to two-thirds-screen
hotkey.bind(mash, "c", function()
    local win = window.focusedwindow()
    local frame = win:frame()
    local sframe = screen:mainscreen():fullframe()
    frame.x = sframe.w / 6.0
    frame.y = 0
    frame.w = sframe.w * (2.0 / 3.0)
    frame.h = sframe.h
    transform:setframe(win, frame, animation_time)
end)

------------------
-- APPLICATIONS --
------------------

local function open_dictionary(message)
    alert.show("Lexicon, at your service.", 0.75)
    application.launchorfocus("Dictionary")
end

hotkey.bind(shiftmash, 'd', open_dictionary)

local function open_iterm()
    alert.show("Terminal!", 0.75)
    application.launchorfocus("terminal.app")
end

hotkey.bind(mash, 'return', open_iterm)
