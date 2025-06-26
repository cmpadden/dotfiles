test:
	hs -c "dofile(hs.configdir .. '/tests/test_basic_alerts.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_stacking.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_manual_dismissal.lua').run()"
	hs -c "dofile(hs.configdir .. '/tests/test_compatibility.lua').run()"

format:
	stylua --config-path ../../.stylua.toml  .
