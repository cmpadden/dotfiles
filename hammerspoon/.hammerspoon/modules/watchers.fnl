(local helpers (require :modules.helpers))

(local obj {})
(set obj.__index obj)
(set obj.name "Watcher Module")
(set obj.version :0.0.1)

(fn callback [files flag-tables]
  "Displays file events captured by path watcher."
  (let [mods {}]
    (each [ix file (pairs files)]
      (local events {})
      (each [event _ (pairs (. flag-tables ix))]
        (tset events (+ (length events) 1) event))
      (tset mods (+ (length mods) 1)
            {:name (table.concat events ",") :value file}))
    (helpers:show "Downloads Updated" mods)))

(set obj.download-pathwatcher
  (hs.pathwatcher.new (.. (os.getenv :HOME) :/Downloads/) callback))

(obj.download-pathwatcher:start)

obj
