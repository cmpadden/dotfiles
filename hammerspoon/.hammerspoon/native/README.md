# Native glass toast prototype

A centered, click-through, non-activating AppKit panel for caffeine and reload feedback.
`make native` also builds the interactive Launcher chooser; see
[`Launcher.spoon`](../vendored/Launcher.spoon/README.md) for that UI and its API.
Both helpers use `GlassBackground.swift` for the same native material.
Uses `NSGlassEffectView` on macOS 26+ and `NSVisualEffectView` (`hudWindow`)
on macOS 13–25. No notification permission, Dock icon, or Notification Center
history. Accessibility settings such as Reduce Transparency can change the effect.

## Build and preview

Requires Apple Command Line Tools with a macOS 26+ SDK (for the glass API).
From `hammerspoon/.hammerspoon`:

```sh
make native
make preview-glass
```

The preview does **not** change display-sleep prevention. To preview the other state:

```sh
native/.build/glass-toast disabled "Caffeine Disabled" 4
```

To preview startup/reload feedback:

```sh
native/.build/glass-toast reload "Hammerspoon Reloaded" 4
```

Arguments are kind (`enabled`, `disabled`, or `reload`), optional title, and optional hold
seconds (0.2–30; default 2). Invalid arguments exit nonzero with a diagnostic
so Hammerspoon can fall back to canvas. The panel centers on AppKit's main
screen, fades in and out, and exits. Hammerspoon replaces the previous process on rapid toggles.
This short-lived process is intentionally a prototype, not a persistent service.

## Hammerspoon integration

Stow the `hammerspoon` package so `~/.hammerspoon/native` points here, build,
then reload Hammerspoon. Cmd+Ctrl+0 uses the native toast for caffeine;
startup/reload uses it with an `arrow.clockwise` SF Symbol and blue tint.
Other alerts still use the existing canvas renderer. The Lua wrapper falls back
to canvas if the binary is missing or fails to run; it never compiles on a hotkey.

The generated executable lives in ignored `native/.build/`. Rebuild after source
changes; builds replace the executable atomically, and a binary is not distributed
or committed. To disable the prototype, remove `native/.build/glass-toast`;
caffeine and reload will use the canvas again.

## Validation

```sh
hs -c 'dofile(hs.configdir .. "/tests/test_glass_toast.lua").run()'
xcrun swift-format lint --strict native/GlassToast.swift
```

The wrapper tests use mock tasks and do not show UI or change caffeine state.
They cover native launch, replacement, fallback, stale callbacks, and reload
arguments. Preview each kind to check rendering and focus behavior on macOS.
The older-macOS visual-effect fallback requires separate visual testing on an
older host.
