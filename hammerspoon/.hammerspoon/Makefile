.DEFAULT_GOAL := test
.PHONY: test format native preview-glass

NATIVE_BINARIES := native/.build/glass-toast native/.build/native-chooser

native: $(NATIVE_BINARIES)

native/.build/glass-toast: native/GlassToast.swift
native/.build/native-chooser: native/NativeChooser.swift

$(NATIVE_BINARIES): native/GlassBackground.swift
	mkdir -p native/.build
	xcrun swiftc -O -target "$$(uname -m)-apple-macosx13.0" -framework AppKit $^ -o $@.tmp
	mv -f $@.tmp $@

# Visual preview only; does not change caffeine state.
preview-glass: native
	native/.build/glass-toast enabled "Caffeine Enabled" 4

test:
	hs -c "dofile(hs.configdir .. '/tests/test_chooser.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_launcher.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_glass_toast.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_basic_alerts.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_stacking.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_manual_dismissal.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_compatibility.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_window_state.lua').run()"

format:
	stylua --config-path ../../.stylua.toml  .
