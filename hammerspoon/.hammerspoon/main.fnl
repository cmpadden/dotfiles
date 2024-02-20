; global hotkey prefix key combinations (used in modules)
(global HYPER [:cmd :ctrl])
(global HYPER_SHIFT [:cmd :ctrl :shift])

; custom styling for alerts
(set hs.alert.defaultStyle.textColor {:alpha 1 :hex "#000000"})
(set hs.alert.defaultStyle.textFont :Courier)
(set hs.alert.defaultStyle.textSize 12)
(set hs.alert.defaultStyle.fillColor {:alpha 0.95 :hex "#FFFFFF"})
(set hs.alert.defaultStyle.strokeColor {:alpha 0.95 :hex "#000000"})
(set hs.alert.defaultStyle.strokeWidth 2)
(set hs.alert.defaultStyle.padding 12)
(set hs.alert.defaultStyle.radius 1)
(set hs.alert.defaultStyle.fadeInDuration 0)
(set hs.alert.defaultStyle.fadeOutDuration 2)

(require :modules.plugins)
(require :modules.alerts)
(require :modules.caffeine)
; (require :modules.watchers)

(: (require :modules.window) :init)

; https://www.hammerspoon.org/docs/hs.ipc.html#cliInstall
; https://github.com/Hammerspoon/hammerspoon/issues/2930#issuecomment-899092002
(when (not (hs.ipc.cliStatus :/opt/homebrew))
  (hs.ipc.cliInstall :/opt/homebrew))

(hs.alert.show "Completed load of `main.fnl`")
