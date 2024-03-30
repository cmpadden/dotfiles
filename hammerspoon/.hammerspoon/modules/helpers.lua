(local obj {})

(fn obj.get_asset [self filename]
  "Loads image stored in assets directory."
  (hs.image.imageFromPath (.. hs.configdir :/assets/ filename)))

;; Image assets
(set obj.assets {
  :ban (obj:get_asset :ban.png)
  :check (obj:get_asset :check.png)
  :logo (obj:get_asset :logo.png)})

;; Default styles used in alerts
(set obj.styles {
  :error {:fillColor {:alpha 0.95 :hex "#FFCDD2"}}
  :info {:fillColor {:alpha 0.95 :hex "#FFFFFF"}}
  :success {:fillColor {:alpha 0.95 :hex "#DCEDC8"}}
  :warn {:fillColor {:alpha 0.95 :hex "#FFF59D"}}})

(fn rpad [str len]
    (.. str (string.rep " " (- len (length str)))))

(fn lpad [str len]
    (.. (string.rep " " (- len (length str))) str))


(fn obj.show [self title attributes style logo]
  "Stylized alert with images"
  (set-forcibly! style (or style obj.styles.info))
  (set-forcibly! logo (or logo obj.assets.logo))
  (local lines [title])
  (when (not (= attributes nil))
    (tset lines (+ (length lines) 1) (string.rep "-" 80))
    (for [i 1 (length attributes)]
      (tset lines (+ (length lines) 1)
            (.. (rpad (. (. attributes i) :name) 30) ": "
                (. (. attributes i) :value)))))
  (hs.alert.showWithImage (table.concat lines "\n") logo style))

(fn obj.info [self msg]
  "Info level stylized alert"
  (hs.alert.showWithImage msg obj.assets.logo obj.styles.info))

(fn obj.success [self msg]
  "Success level stylized alert"
  (hs.alert.showWithImage msg obj.assets.logo obj.styles.success))

(fn obj.warn [self msg]
  "Warning level stylized alert"
  (hs.alert.showWithImage msg obj.assets.logo obj.styles.warn))

(fn obj.error [self msg]
  "Error level stylized alert"
  (hs.alert.showWithImage msg obj.assets.logo obj.styles.error))

(fn obj.sleep [ms]
  "Delays execution for `ms` milliseconds"
  (os.execute (.. "sleep " (/ (tonumber ms) 1000))))

(fn obj.led_blinker [self]
  "Blinks `hid.led` 10 times with 100 ms cycle"
  (for [_ 1 10] (obj:sleep 100) (hs.hid.led.set :caps true) (obj:sleep 100)
    (hs.hid.led.set :caps false)))

obj
