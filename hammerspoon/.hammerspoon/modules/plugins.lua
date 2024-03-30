hs.loadSpoon("SpoonInstall")

spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

spoon.SpoonInstall:andUse("LookupSelection", { hotkeys = { lexicon = { HYPER, "d" } } })

spoon.SpoonInstall:andUse("AppLauncher", {
    config = { modifiers = HYPER },
    hotkeys = {
        i = "Chromium",
        k = "kitty",
        m = "Mail",
        n = "Notion",
        l = "Linear",
        s = "Slack",
    },
})

spoon.SpoonInstall:andUse("KSheet", { hotkeys = { toggle = { HYPER, "/" } } })

local app_search_paths = {
    "/Applications",
    "/System/Applications",
    "~/Applications",
    "/Developer/Applications",
    "/Applications/Xcode.app/Contents/Applications",
    "/System/Library/PreferencePanes",
    "/Library/PreferencePanes",
    "~/Library/PreferencePanes",
    "/System/Library/CoreServices/Applications",
    "/usr/local/Cellar",
}

spoon.SpoonInstall:andUse("Seal", {
    fn = function(s)
        s:loadPlugins({ "apps", "calc", "screencapture", "useractions" })
        s.plugins.useractions.actions = {
            ["Translate w/ Google Translate"] = {
                icon = "favicon",
                keyword = "tr",
                url = "https://translate.google.com/?sl=en&tl=fr&text=${query}&op=translate",
            },
        }
        s.plugins.apps.appSearchPaths = app_search_paths
        do
        end
        (s.plugins.apps):restart()
        return s:refreshAllCommands()
    end,
    hotkeys = { show = { { "cmd" }, "p" } },
    start = true,
})
