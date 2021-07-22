-- ~/.hammerspoon/init.lua

-- https://www.hammerspoon.org/go/
-- https://www.hammerspoon.org/Spoons/index.html
-- https://www.hammerspoon.org/Spoons/SpoonInstall.html
-- https://github.com/zzamboni/dot-hammerspoon/blob/master/init.org#spoon-management

--------------------------------------------------------------------------------
--                               Configuration                                --
--------------------------------------------------------------------------------

-- hotkey prefix key combinations
local hyper       = {'cmd', 'ctrl'}
local hyper_shift = {'cmd', 'ctrl', 'shift'}

-- custom styling for alerts
hs.alert.defaultStyle.textColor       = { hex = '#000000', alpha = 1 }
hs.alert.defaultStyle.textFont        = 'Courier'
hs.alert.defaultStyle.textSize        = 14
hs.alert.defaultStyle.fillColor       = { hex = '#FFFFFF', alpha = 0.90 }
hs.alert.defaultStyle.strokeColor     = { hex = '#000000', alpha = 0.90 }
hs.alert.defaultStyle.strokeWidth     = 2
hs.alert.defaultStyle.radius          = 1
hs.alert.defaultStyle.fadeInDuration  = 0
hs.alert.defaultStyle.fadeOutDuration = 1

--------------------------------------------------------------------------------
--                                  Plugins                                   --
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/SpoonInstall.html

hs.loadSpoon("SpoonInstall")

-- https://www.hammerspoon.org/Spoons/PopupTranslateSelection.html

spoon.SpoonInstall:andUse('PopupTranslateSelection', {
  hotkeys = {
    translate = { hyper, "t" },
    translate_fr_en = { hyper_shift, 'e' },
    translate_en_fr = { hyper_shift, 'f' },
  },
  config = {
    popup_size = hs.geometry.size(400, 600)
  }
 })

-- https://www.hammerspoon.org/Spoons/Emojis.html

spoon.SpoonInstall:andUse('Emojis', {
  hotkeys = {
    toggle = { hyper, "e" },
  }
})

-- https://www.hammerspoon.org/Spoons/LookupSelection.html

spoon.SpoonInstall:andUse('LookupSelection', {
  hotkeys = {
    lexicon = { hyper, "d" },
  },
})

-- https://www.hammerspoon.org/Spoons/AppLauncher.html

spoon.SpoonInstall:andUse("AppLauncher", {
  hotkeys = {
    c = "Calendar",
    k = "kitty",
    l = "Slack",
    m = "Mail",
    n = "Notion",
    p = "Spotify",
    s = "Safari",
    z = "zoom.us",
  },
  config = {
    modifiers = hyper
  }
})

-- https://www.hammerspoon.org/Spoons/KSheet.html

spoon.SpoonInstall:andUse("KSheet", {
  hotkeys = {
    toggle = { hyper, "/" }
  }
})

-- https://www.hammerspoon.org/Spoons/Seal.html

spoon.SpoonInstall:andUse("Seal",
  {
    hotkeys = { show = { {"cmd"}, "space" } },
    fn = function(s)
      s:loadPlugins({
        "apps",
        "calc",
        "screencapture",
        "useractions"
      })
      s.plugins.useractions.actions = {
        ["Translate w/ Google Translate"] = {
          url = "https://translate.google.com/?sl=en&tl=fr&text=${query}&op=translate",
          icon = 'favicon',
          keyword = "tr",
        }
      }
      s:refreshAllCommands()
    end,
    start = true,
  }
)

--------------------------------------------------------------------------------
--                             Information Alerts                             --
--------------------------------------------------------------------------------

hs.hotkey.bind(hyper, "x", function()
  hs.alert.show(
    string.format('%s\nBattery: %.2f %%',
      os.date("%A, %B %d, %Y %X"),
      hs.battery.capacity() / hs.battery.maxCapacity() * 100
    )
  )
end)

hs.hotkey.bind(hyper, "0", function()
  hs.reload()
end)

-- https://www.hammerspoon.org/docs/hs.spotify.html

hs.hotkey.bind(hyper, "2", function()
  hs.spotify.displayCurrentTrack()
end)

--------------------------------------------------------------------------------
--                             Window Management                              --
--------------------------------------------------------------------------------

-- TODO : automatically manage windows on event detection

hs.window.animationDuration = 0

-- https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

spoon.SpoonInstall:andUse('WindowScreenLeftAndRight', {
  hotkeys = {
    screen_left = { { 'cmd', 'shift' }, "Left" },
    screen_right= { { 'cmd' ,'shift' }, "Right" },
  },
})

-- https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html

spoon.SpoonInstall:andUse('WindowHalfsAndThirds', {
  hotkeys = {
    left_half = { { 'cmd' }, "Left" },
    right_half = { { 'cmd' }, "Right" },
    max_toggle = { { 'cmd', 'shift' }, "Up" },
    center = { { 'cmd' }, "Up" },
  },
})

-- https://www.hammerspoon.org/go/#winlayout

hs.hotkey.bind({ "cmd", "ctrl" }, "1", function()

  local display_primary = hs.screen.allScreens()[1]:name()
  local display_secondary = hs.screen.allScreens()[1]:name()

  local num_screens = #hs.screen.allScreens()
  if num_screens > 1 then
    -- hs.alert.show(hs.screen.allScreens()[1]:name())
    -- hs.alert.show(hs.screen.allScreens()[2]:name())
    display_secondary = hs.screen.allScreens()[2]:name()
  end


  local window_layout = {
    {"Safari",    nil, display_primary,   hs.layout.maximized, nil, nil},
    {"Notion",    nil, display_secondary, hs.layout.maximized, nil, nil},
    {"Spotify",   nil, display_secondary, hs.layout.maximized, nil, nil},
    {"Slack",     nil, display_secondary, hs.layout.maximized, nil, nil},
    {"Calendar",  nil, display_secondary, hs.layout.maximized, nil, nil},
    {"Mail",      nil, display_secondary, hs.layout.maximized, nil, nil},
  }

  hs.alert.show(
     string.format([[
Primary Window Layout
----------------------------------------
Display #1: %s
Display #2: %s]], display_primary, display_secondary)
  )
  hs.layout.apply(window_layout)

end)

--------------------------------------------------------------------------------
--                              Caffeine Utility                              --
--------------------------------------------------------------------------------

-- https://gist.github.com/heptal/50998f66de5aba955c00

-- CAFFEINE_ON_ICON = [[ASCII:
-- .....1a..........AC..........E
-- ..............................
-- ......4.......................
-- 1..........aA..........CE.....
-- e.2......4.3...........h......
-- ..............................
-- ..............................
-- .......................h......
-- e.2......6.3..........t..q....
-- 5..........c..........s.......
-- ......6..................q....
-- ......................s..t....
-- .....5c.......................
-- ]]

-- CAFFEINE_OFF_ICON = [[ASCII:
-- .....1a.....x....AC.y.......zE
-- ..............................
-- ......4.......................
-- 1..........aA..........CE.....
-- e.2......4.3...........h......
-- ..............................
-- ..............................
-- .......................h......
-- e.2......6.3..........t..q....
-- 5..........c..........s.......
-- ......6..................q....
-- ......................s..t....
-- ...x.5c....y.......z..........
-- ]]

-- local caffeine = hs.menubar.new()

-- local function setCaffeineDisplay(state)
--     if state then
--         caffeine:setIcon(CAFFEINE_ON_ICON)
--     else
--         caffeine:setIcon(CAFFEINE_OFF_ICON)
--     end
-- end

-- local function caffeineClicked()
--     setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
-- end

-- if caffeine then
--     caffeine:setClickCallback(caffeineClicked)
--     setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
-- end


