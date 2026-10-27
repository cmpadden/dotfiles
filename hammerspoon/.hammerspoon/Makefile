.DEFAULT_GOAL := test
.PHONY: test format native preview-glass

NATIVE_BINARY := native/.build/glass-toast

native: $(NATIVE_BINARY)

$(NATIVE_BINARY): native/GlassToast.swift
	mkdir -p native/.build
	xcrun swiftc -O -target "$$(uname -m)-apple-macosx13.0" -framework AppKit $< -o $@.tmp
	mv -f $@.tmp $@

# Visual preview only; does not change caffeine state.
preview-glass: native
	$(NATIVE_BINARY) enabled "Caffeine Enabled" 4

test:
	hs -c "dofile(hs.configdir .. '/tests/test_glass_toast.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_basic_alerts.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_stacking.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_manual_dismissal.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_compatibility.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_window_state.lua').run()"

format:
	stylua --config-path ../../.stylua.toml  .
