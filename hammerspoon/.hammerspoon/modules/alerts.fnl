(local helpers (require :modules.helpers))

(hs.hotkey.bind HYPER :9 (fn [] (hs.spotify.displayCurrentTrack)))

(hs.hotkey.bind HYPER :x
                (fn []
                  (let [attrs {}]
                    (tset attrs (+ (length attrs) 1)
                          {:name "System Time"
                           :value (os.date "%A, %B %d, %Y %X")})
                    (local battery-capacity (hs.battery.capacity))
                    (local max-battery-capacity (hs.battery.maxCapacity))
                    (when (not (and (= battery-capacity nil)
                                    (= max-battery-capacity nil)))
                      (tset attrs (+ (length attrs) 1)
                            {:name "Battery Capacity"
                             :value (* (/ battery-capacity max-battery-capacity)
                                       100)}))
                    (tset attrs (+ (length attrs) 1)
                          {:name :Caffeine
                           :value (tostring (hs.caffeinate.get :displayIdle))})
                    (helpers:show "System Information" attrs
                                  helpers.styles.success))))	
