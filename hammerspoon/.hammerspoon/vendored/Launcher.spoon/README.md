# Launcher.spoon

A local fork of Seal's plugin engine using `require("modules.chooser")` for a
native glass UI. The normal shortcut remains **Cmd+P**. Lua retains matching,
plugin actions, original choice objects, Spotlight indexing, and user settings;
Swift owns text input, result rendering, keyboard navigation, and focus.

## Upstream and local changes

Vendored from [Hammerspoon/Spoons, Source/Seal.spoon](https://github.com/Hammerspoon/Spoons/tree/2ecaa0523fcf4f90521db9ed5e41749c366dd6b9/Source/Seal.spoon)
at revision `2ecaa0523fcf4f90521db9ed5e41749c366dd6b9`, licensed MIT by Chris
Jones and contributors. The four configured plugins are included: `apps`,
`calc`, `screencapture`, and `useractions`. Plugin files retain upstream names,
`plugin.seal`, and `seal_*` settings keys so existing bookmarks/actions survive.
Additional Seal plugins can be supplied via `launcher_plugins` or `seal_plugins`.

The core is adapted to use the native chooser, avoid global scratch variables,
keep command prompts open, remove obsolete dynamic commands, and sort results.
The vendored apps/useractions plugins use literal search matching so punctuation
is not treated as a Lua pattern; apps' icon/bundle variables are now local.
Other plugin behavior is intentionally retained. This is not a general plugin
sandbox: plugins run Lua in Hammerspoon with the same access as before.

This directory is tracked declarative source under `vendored`, distinct
from ignored, downloaded `Spoons`. `hs.loadSpoon` resolves it via `package.path`;
SpoonInstall does not download, update, or overwrite Launcher.

## Build and use

Requires Apple Command Line Tools with a macOS 26+ SDK. Stow the `hammerspoon`
package, run `make -C ~/.hammerspoon native`, and reload Hammerspoon.
Use Cmd+P, type a query, then Up/Down and Return to select. Double-click also
selects; Escape or clicking another app cancels. Standard Cmd+A/C/V/X/Z editing
shortcuts are supported. The panel hides and requests previous-app focus before
returning the selected result to Lua. Removing the binary disables the
launcher and reports build instructions; there is **no hs.chooser fallback**.

## Native chooser boundary

`modules.chooser.new(completion)` implements the subset used by Launcher:

- `choices(table | function | nil)`, `refreshChoicesCallback()`
- `query([string | nil])`, `queryChangedCallback(fn)`
- `show([position])`, `hide()`, `cancel()`, `isVisible()`, `delete()`
- `select([row])`, `selectedRow([row])`, `selectedRowContents([row])`
- `showCallback(fn)`, `hideCallback(fn)`, `invalidCallback(fn)`
- `rows([count])`, `width([screenPercent])`, `placeholderText([text])`,
  `searchSubText([boolean])`
- `maxWidth([points])`: native extension, defaults to 640 points so the launcher
  stays compact on large displays; `width` sets a percentage within that cap

Rows are one-based. Choice metadata stays in Lua; only display text, subtext,
resized PNG icons, and row selection cross the process boundary. `valid=false`
invokes the invalid callback without hiding. Static choices are filtered by
literal case-insensitive text; callback choices are already matched by Lua.
`hide` does not invoke completion, while `cancel` completes with nil. Actions
and hide callbacks wait for the native window to actually hide.

This is **not full hs.chooser parity**. Rich styled text is flattened to plain
text. Toolbars, right-click menus, custom foreground/background colors, global
callbacks, and default-for-query behavior are not implemented. Refresh is eager,
not a replica of hs.chooser's cached callback behavior. Rows/width are bounded
to 1–100; maximum width must be finite and at least 360 points. Callbacks
returning choices retain original Lua objects. The global
`hs.chooser` is never patched. Native typing and programmatic queries share the
same update path: static choices filter immediately, while a dynamic source's
query callback controls debounced refresh. Display-only options update the UI
without rerunning plugin matching.

The native process is persistent while Hammerspoon runs, communicating over
newline-delimited JSON on stdin/stdout. Full snapshots are acknowledged one at
a time and pending snapshots coalesce, since `hs.task:setInput` otherwise drops
unwritten bytes. Session/revision/input counters reject stale selections and
prevent old results from replacing newer typing. EOF and the chained shutdown
callback close the helper on reload without losing window-state persistence.

## Validation

```sh
hs -c 'dofile(hs.configdir .. "/tests/test_chooser.lua").run()'
hs -c 'dofile(hs.configdir .. "/tests/test_launcher.lua").run()'
xcrun swift-format lint --strict ~/.hammerspoon/native/NativeChooser.swift
```

Adapter and engine tests use mocked processes/UI and execute no plugin actions.
Native integration also needs a macOS visual/input test. The material fallback
on macOS 13–25 has not been visually tested on an older host.
