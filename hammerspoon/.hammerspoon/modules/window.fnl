;;; Window Management Module
;;
;; References
;; - https://www.hammerspoon.org/go/#winlayout
;; - https://www.hammerspoon.org/Spoons/WindowHalfsAndThirds.html
;; - https://www.hammerspoon.org/Spoons/WindowScreenLeftAndRight.html

(local obj {})
(set obj.__index obj)
(set obj.name "Window Management")
(set obj.version :1.0.0)

(set obj.config {
  :default-layout 3
  :split-padding 0.1
  :padding 0.02
  :window-width-centered 0.65})

(global RECT_CENTER (hs.geometry {
  :h (- 1 (* 2 obj.config.padding))
  :w obj.config.window-width-centered
  :x (/ (- 1 obj.config.window-width-centered) 2)
  :y obj.config.padding}))

;; TODO - look into scaled padding based on display aspect ratio

(global RECT_LEFT (hs.geometry {
  :h (- 1 (* 2 obj.config.padding))
  :w (- 0.5 (+ obj.config.split-padding 0.005))
  :x obj.config.split-padding
  :y obj.config.padding}))

(global RECT_RIGHT (hs.geometry {
  :h (- 1 (* 2 obj.config.padding))
  :w (- 0.5 obj.config.split-padding 0.005)
  :x (+ 0.5 0.005)
  :y obj.config.padding}))


(global LAYOUTS {
  1 {
    :Alacritty hs.layout.maximized
    :Arc hs.layout.maximized
    "Bitwig Studio" hs.layout.maximized
    "Brave Browser" hs.layout.maximized
    :Calendar hs.layout.maximized
    :Chromium hs.layout.maximized
    :Discord hs.layout.maximized
    :Firefox hs.layout.maximized
    "Google Chrome" hs.layout.maximized
    :LibreWolf hs.layout.maximized
    "Logic Pro" hs.layout.maximized
    :Mail hs.layout.maximized
    :Messages hs.layout.maximized
    :Notes hs.layout.maximized
    :Notion hs.layout.maximized
    :Safari hs.layout.maximized
    :Slack hs.layout.maximized
    :Spotify hs.layout.maximized
    :Terminal hs.layout.maximized
    :kitty hs.layout.maximized
    :zoom.us hs.layout.maximized
    }
  2 {
    :Alacritty RECT_LEFT
    :Arc RECT_RIGHT
    "Bitwig Studio" RECT_LEFT
    "Brave Browser" RECT_RIGHT
    :Calendar RECT_RIGHT
    :Chromium RECT_RIGHT
    :Discord RECT_RIGHT
    :Firefox RECT_RIGHT
    "Google Chrome" RECT_RIGHT
    :LibreWolf RECT_RIGHT
    "Logic Pro" RECT_RIGHT
    :Mail RECT_RIGHT
    :Messages RECT_RIGHT
    :Notes RECT_RIGHT
    :Notion RECT_RIGHT
    :Safari RECT_RIGHT
    :Slack RECT_RIGHT
    :Spotify RECT_RIGHT
    :Terminal RECT_LEFT
    :kitty RECT_LEFT
    :zoom.us RECT_RIGHT
    }
  3 {
    :Alacritty RECT_CENTER
    :Arc RECT_CENTER
    "Bitwig Studio" RECT_CENTER
    "Brave Browser" RECT_CENTER
    :Calendar RECT_CENTER
    :Chromium RECT_CENTER
    :Discord RECT_CENTER
    :Figma RECT_CENTER
    :Firefox RECT_CENTER
    "Google Chrome" RECT_CENTER
    :LibreWolf RECT_CENTER
    "Logic Pro" RECT_CENTER
    :Mail RECT_CENTER
    :Messages RECT_CENTER
    :Notes RECT_CENTER
    :Notion RECT_CENTER
    :Safari RECT_CENTER
    :Slack RECT_CENTER
    :Spotify RECT_CENTER
    :Terminal RECT_CENTER
    :kitty RECT_CENTER
    :zoom.us RECT_CENTER
    }})

; TODO - explore if pattern matching on window layouts is more elegant

(fn resize-window [window app-name]
  "Resize `window` to defined size for given cached `obj.layout`"
  (local target-app-layout (. (. LAYOUTS obj.layout) app-name))
  (if (not= target-app-layout nil)
    (window:moveToUnit target-app-layout)))

(fn obj.set_layout [self layout]
  "Set all `active-windows` to destined `active-layout`"
  (set self.layout layout)
  (local active-layout (. LAYOUTS layout))
  (local active-windows (hs.window.filter.default:getWindows))
  (each [_ w (ipairs active-windows)]
    (local app-name (: (w:application) :name))
    (when (not= (. active-layout app-name) nil)
      (w:moveToUnit (. active-layout app-name)))))

(fn obj.init [self]
  "Sets default layout, subscribes to window creation events, and sets key bindings"
  (set self.layout obj.config.default-layout)
  (hs.window.filter.default:subscribe hs.window.filter.windowCreated resize-window)
  (set hs.window.animationDuration 0)
  (hs.hotkey.bind [:cmd :ctrl] :1 (fn [] (obj:set_layout 1)))
  (hs.hotkey.bind [:cmd :ctrl] :2 (fn [] (obj:set_layout 2)))
  (hs.hotkey.bind [:cmd :ctrl] :3 (fn [] (obj:set_layout 3))))

obj
