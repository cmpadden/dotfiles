(local helpers (require :modules.helpers))

(local HYPER [:cmd :ctrl])

(hs.hotkey.bind HYPER :0
                (fn [] (hs.caffeinate.toggle :displayIdle)
                  (if (hs.caffeinate.get :displayIdle)
                      (helpers:show "Caffeine Enabled" nil
                                    helpers.styles.success helpers.assets.check)
                      (helpers:show "Caffeine Disabled" nil
                                    helpers.styles.error helpers.assets.ban))))
