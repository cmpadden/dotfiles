.DEFAULT_GOAL := test
.PHONY: test format native preview-glass test-glass-geometry

NATIVE_BINARIES := native/.build/glass-toast native/.build/native-chooser
SWIFT_FLAGS ?= -O

native: $(NATIVE_BINARIES)

native/.build/glass-toast: native/GlassToast.swift
native/.build/native-chooser: native/NativeChooser.swift
# Keep assertions enabled in the geometry test executable.
native/.build/test-glass-geometry: SWIFT_FLAGS = -Onone
native/.build/test-glass-geometry: tests/test_glass_geometry.swift

$(NATIVE_BINARIES) native/.build/test-glass-geometry: native/GlassBackground.swift
	mkdir -p native/.build
	xcrun swiftc $(SWIFT_FLAGS) -target "$$(uname -m)-apple-macosx13.0" -framework AppKit $^ -o $@.tmp
	mv -f $@.tmp $@

# Visual preview only; does not change caffeine state.
preview-glass: native
	native/.build/glass-toast enabled "Caffeine Enabled" 4

test-glass-geometry: native/.build/test-glass-geometry
	native/.build/test-glass-geometry

test: test-glass-geometry
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
