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

(_G.spoon.SpoonInstall:andUse :Seal {
  :fn (fn [s]
    (s:loadPlugins [:apps :calc :screencapture :useractions])
    (set s.plugins.useractions.actions {
       "Translate w/ Google Translate" {:icon :favicon
       :keyword :tr
       :url "https://translate.google.com/?sl=en&tl=fr&text=${query}&op=translate"}})
    (s:refreshAllCommands))
  :hotkeys {:show [[:cmd] :p]}
  :start true})
