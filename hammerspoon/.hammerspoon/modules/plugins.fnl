(hs.loadSpoon :SpoonInstall)

(_G.spoon.SpoonInstall:andUse :ReloadConfiguration {:start true})

(_G.spoon.SpoonInstall:andUse :LookupSelection {:hotkeys {:lexicon [HYPER :d]}})

(_G.spoon.SpoonInstall:andUse :AppLauncher {
  :config {:modifiers HYPER}
  :hotkeys {
    :i "Google Chrome"
    :k :kitty
    :m :Mail
    :n :Notion
    :s :Slack}})

(_G.spoon.SpoonInstall:andUse :KSheet {
  :hotkeys {
    :toggle [HYPER "/"]}})

; override default search paths for the `app` plugin
; https://github.com/Hammerspoon/Spoons/blob/5de05501a0bf8a691756e10469c190dce4f7c34e/Source/Seal.spoon/seal_apps.lua#L15
(local app-search-paths [
  "/Applications"
  "/System/Applications"
  "~/Applications"
  "/Developer/Applications"
  "/Applications/Xcode.app/Contents/Applications"
  "/System/Library/PreferencePanes"
  "/Library/PreferencePanes"
  "~/Library/PreferencePanes"
  "/System/Library/CoreServices/Applications"
  ; "/System/Library/CoreServices/"
  "/usr/local/Cellar"
  ; "/Library/Scripts"
  ; "~/Library/Scripts"
])

(_G.spoon.SpoonInstall:andUse :Seal {
  :fn (fn [s]
    (s:loadPlugins [:apps :calc :screencapture :useractions])
    (set s.plugins.useractions.actions {
       "Translate w/ Google Translate" {:icon :favicon
       :keyword :tr
       :url "https://translate.google.com/?sl=en&tl=fr&text=${query}&op=translate"}})
    (set s.plugins.apps.appSearchPaths app-search-paths)
    (s.plugins.apps:restart)
    (s:refreshAllCommands))
  :hotkeys {:show [[:cmd] :p]}
  :start true})
