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

## Corner geometry

Apple recommends native materials and rounded shapes that nest concentrically;
it does not prescribe a single numerical radius for all custom macOS panels.
See [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass)
and [ConcentricRectangle](https://developer.apple.com/documentation/swiftui/concentricrectangle)
for the design principle, and [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
for guidance on using regular glass for text-heavy overlays.

`GlassGeometry` in `GlassBackground.swift` owns our chosen dimensions:

- Toast: 16-point outer radius, 360×64-point visible surface. The radius matches
  AppKit's reported effective corners for a standard titled, resizable window
  on the current macOS host; it is not a universal value for every window style.
- Launcher: 16-point outer radius, matching the toast and the measured window style.
- Result selection: 14-point visible margin at the sides and bottom, with a
  radius derived as `outerRadius - margin` (currently 2 points). The bottom
  margin includes the scroll viewport and row inset; viewport height fits whole
  rows so there is no extra gap that shifts the corner centers.
- Selection highlights use Core Animation's continuous corner curve, not an
  independently drawn circular arc. The older-macOS material fallback uses the
  same curve; current glass surfaces keep AppKit's own rendering.
- The transparent 24-point shadow margin is outside the visible surface and is
  deliberately excluded from nested-corner calculations.

These are app-specific values following the concentric-layout principle, not
claimed system notification metrics or a replica of Apple's private geometry.
There is one glass surface per panel, with a plain translucent selection fill,
not additional layers of glass for rows. This keeps the existing macOS 26 SDK
build requirement; it does not depend on macOS 27's corner-resolution APIs.

## Validation

```sh
make test-glass-geometry
hs -c 'dofile(hs.configdir .. "/tests/test_glass_toast.lua").run()'
xcrun swift-format lint --strict native/*.swift tests/test_glass_geometry.swift
```

The wrapper tests use mock tasks and do not show UI or change caffeine state.
They cover native launch, replacement, fallback, stale callbacks, and reload
arguments. Preview each kind to check rendering and focus behavior on macOS.
The older-macOS visual-effect fallback requires separate visual testing on an
older host.
