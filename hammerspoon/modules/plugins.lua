--------------------------------------------------------------------------------
--                                   Spoons                                   --
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/SpoonInstall.html
hs.loadSpoon("SpoonInstall")

-- http://www.hammerspoon.org/Spoons/ReloadConfiguration.html
spoon.SpoonInstall:andUse('ReloadConfiguration', {
    start = true
})

-- initialization of this plugin is slow, need to debug
-- https://www.hammerspoon.org/Spoons/Emojis.html
-- spoon.SpoonInstall:andUse('Emojis', {
--   hotkeys = {
--     toggle = { hyper, "e" },
--   }
-- })

-- https://www.hammerspoon.org/Spoons/PopupTranslateSelection.html
spoon.SpoonInstall:andUse('PopupTranslateSelection', {
  hotkeys = {
    translate = { HYPER, "t" },
    translate_fr_en = { HYPER_SHIFT, 'e' },
    translate_en_fr = { HYPER_SHIFT, 'f' },
  },
  config = {
    popup_size = hs.geometry.size(400, 600)
  }
 })

-- https://www.hammerspoon.org/Spoons/LookupSelection.html
spoon.SpoonInstall:andUse('LookupSelection', {
  hotkeys = {
    lexicon = { HYPER, "d" },
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
    modifiers = HYPER
  }
})

-- https://www.hammerspoon.org/Spoons/KSheet.html
spoon.SpoonInstall:andUse("KSheet", {
  hotkeys = {
    toggle = { HYPER, "/" }
  }
})

-- https://www.hammerspoon.org/Spoons/Seal.html
spoon.SpoonInstall:andUse("Seal",
  {
    hotkeys = { show = { {"cmd"}, "p" } },
    fn = function(s)
      s:loadPlugins({
        "apps",
        "calc",
        "screencapture", -- sc
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
