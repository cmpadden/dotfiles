hs.loadSpoon("SpoonInstall")

-- Stow links the config into $HOME. FSEvents does not follow those links into the checkout.
local init_path = hs.fs.pathToAbsolute(hs.configdir .. "/init.lua")
local source_dir = init_path and init_path:match("^(.+)/[^/]+$") or hs.configdir
spoon.SpoonInstall:andUse("ReloadConfiguration", {
    config = { watch_paths = { source_dir } },
    start = true,
})

spoon.SpoonInstall:andUse("LookupSelection", { hotkeys = { lexicon = { HYPER, "d" } } })

spoon.SpoonInstall:andUse("AppLauncher", {
    config = { modifiers = HYPER },
    hotkeys = {
        g = "ghosty",
        i = "Firefox",
        m = "Mail",
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

-- Locally maintained Spoons are declarative source, not SpoonInstall downloads.
package.path = hs.configdir .. "/vendored/?.spoon/init.lua;" .. package.path
local launcher = hs.loadSpoon("Launcher")
launcher:loadPlugins({ "apps", "calc", "screencapture", "useractions" })
launcher.plugins.useractions.actions = {
    ["Translate w/ Google Translate"] = {
        icon = "favicon",
        keyword = "tr",
        url = "https://translate.google.com/?sl=en&tl=fr&text=${query}&op=translate",
    },
}
launcher.plugins.apps.appSearchPaths = app_search_paths
launcher.plugins.apps:restart()
launcher:refreshAllCommands():bindHotkeys({ show = { { "cmd" }, "p" } }):start()
