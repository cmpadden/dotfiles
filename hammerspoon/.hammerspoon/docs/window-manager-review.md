# Window manager (`modules/window.lua`) review

A code review of the window management module, documenting bugs, quick wins,
refactoring opportunities, and a possible re-architecture.

## Status

Addressed — the module now lives in `modules/wm/` (`init.lua`, `geometry.lua`,
`state.lua`, `actions.lua`, `util.lua`), covering:

- All items under **Bugs and correctness issues**, **Quick wins**,
  **Performance**, and **Refactoring** (state JSON key round trip, guarded
  `load_state`, `moveOneScreenWest/East`, `pip_top_right` position, shared
  manageability predicate, `window_key` fallback, config-driven bindings,
  `hs.logger`, modulo cycling, named geometry constants, shared
  `apply_geometry`, deferred window filter, `setFrameCorrectness` off by
  default behind `config.set_frame_correctness`, per-app AX cache, ignore
  set, re-entrant `init()`/`stop()`, path-aware `get_config`, auto
  persistence via `hs.shutdownCallback`).
- **Testing**: `tests/test_window_state.lua`, wired into `make test`.

Deferred (by design — see "Re-architecture (larger, optional)"): Spoon
conversion, named layouts, multi-monitor support, and replacing the window
filter with an application watcher.

## Bugs and correctness issues

### State persistence silently loses data across the JSON round trip

`obj.state` is keyed by *numeric* layout index (`state[2] = { ... }`), but JSON
objects only have string keys. After `save_state` → `load_state`, the table
becomes `state["2"]`, so every lookup via `obj.state[self.layout]` misses and
restored state is silently ignored. Fix by stringifying keys consistently
(e.g. always `tostring(layout)`) or converting keys back to numbers on load.

### `load_state` has no error handling

`hs.json.read` returns `nil` for a missing/corrupt file, which sets
`obj.state = nil` and crashes the next `ensure_layout_state` call. Guard the
result and fall back to `{}` with a warning alert.

### `moveToScreen(2)` errors on single-display setups

`hs.window.focusedWindow():moveToScreen(screens[index])` passes `nil` when
fewer screens exist. Also, `hs.screen.allScreens()` ordering is not stable;
prefer `window:moveOneScreenWest()` / `moveOneScreenEast()` for "next/previous
screen" semantics (matching the existing TODO).

### `pip_top_right` is actually top-left

The geometry uses `x = padding`, which places the window at the top-left.
Either rename it or set `x = 1 - pip_width - padding` (see the magic-number
cleanup below).

### `set_layout` moves *all* windows, including dialogs and popups

The `windowCreated` handler correctly restricts itself to
`isStandard() and isMaximizable()` windows, but `set_layout` deliberately
"skips all validation" and moves everything, including modal dialogs, pickers,
and floating panels. The two paths should share one predicate
(`is_manageable(window)`).

### `get_window_id` fallback collides

On failure it returns `"unknown_0"` for every window, so distinct windows can
share state entries. Use the raw `window:id()` when the app name is missing,
and skip state entirely when both lookups fail.

### Hotkey collision risk on `cmd+ctrl+h/l`

`cmd+ctrl+h` / `cmd+ctrl+l` are hard-coded for `moveToScreen`, while layouts
bind `cmd+ctrl+<n>` and cycling binds `cmd+shift+h/l`. The screen bindings are
not routed through `config.bindings` like everything else, and they shadow the
mnemonic h/l pair used for cycling. Move them into `config.bindings`.

## Quick wins

- **Replace `print` with `hs.logger`.** `set_layout` prints ~4 lines per
  window on every layout switch. An `hs.logger` instance with a configurable
  level keeps the diagnostics but silences the default path. Same for the
  `windowCreated` "Initializing …" `hs.alert`, which fires for every new
  window; make it opt-in or route it through `helpers` at a debug level.
- **Simplify `next_index_circular` with modulo.** The "hacky workaround" in
  the comment is unnecessary: `return ((index - 1 + step) % #t) + 1` handles
  every step size and direction, including `#t == 1`.
- **Name the magic numbers.** `0.162` is `pip_width + padding`, `0.005` is a
  half-gutter for the split layouts. Deriving them
  (`local half_gap = 0.005`, `x = 1 - pip_width - padding`) makes the
  geometry table self-documenting.
- **Deduplicate the pcall-wrapped app-name lookups.** `get_window_id`,
  `should_ignore_window`, `set_layout`, and `debug_window_filter` each
  re-implement `pcall(function() return window:application():name() end)`.
  Extract `local function app_name(window)` and reuse it.
- **Share the "move window to its geometry" logic.** The `windowCreated`
  handler and `move_focused_window_next_geometry` duplicate the
  lookup-index → `disable_ax_enhanced_ui` → `moveToUnit` sequence (the file's
  own TODO notes this). `set_layout` also skips `disable_ax_enhanced_ui`
  entirely, so bulk moves are less reliable than single-window moves — one
  `apply_geometry(window, layout, index)` helper fixes both.
- **Consistent `self` vs `obj`.** Methods mix `self.layouts` with `obj.state`
  and `obj.config`. It works because the module is a singleton, but pick one
  convention (plain `obj`, since colon-method dispatch buys nothing here).
- **Fix the stale comment.** "Store the most layout index" → "Store the most
  recent geometry index".

## Performance

Startup profiling (5 reload samples) showed `wm:init()` costs ~45 ms, the
single largest item in config load:

- `hs.window.filter` require alone is ~5–6 ms; creating an unrestricted
  `hs.window.filter.new()` and subscribing does the rest. Options:
  - Defer filter creation with `hs.timer.doAfter(0, ...)` so hotkeys are
    available immediately and the filter warms up just after load.
  - Scope the filter (e.g. `hs.window.filter.new():setDefaultFilter{}` or a
    curated app list) rather than watching everything.
- `hs.window.setFrameCorrectness = true` is a global slow path in Hammerspoon
  (it re-verifies frames after every move). Given `disable_ax_enhanced_ui`
  already addresses the Firefox resize problem, benchmark whether frame
  correctness is still needed.
- `disable_ax_enhanced_ui` performs AX calls on every cycle keypress. Cache
  per-application (it only needs to happen once per app per session).
- `should_ignore_window` walks the ignore list per event; a set
  (`{ ["zoom.us"] = true }`) built once in `init` makes it O(1).

## Refactoring

Current file mixes five concerns in one 500-line module: geometry presets,
config plumbing, state store, window operations, and bindings/event wiring.
A low-risk split that keeps the public API identical:

```
modules/wm/init.lua        -- obj, config, init(), public API
modules/wm/geometry.lua    -- builtins + padding constants
modules/wm/state.lua       -- get/set index, cleanup, save/load (JSON key fix)
modules/wm/actions.lua     -- apply_geometry, cycle, set_layout, move screen
```

Along the way:

- **Make `init` re-entrant / add `stop()`.** Hotkeys and filter subscriptions
  are never retained, so they cannot be unbound. Store them
  (`self._hotkeys`, `self._filter`) and unbind in `stop()`; call `stop()` at
  the top of `init()`. This also enables tests to set up/tear down cleanly.
- **Drop `get_config` or make it total.** It raises for `nil` values, which
  turns a missing optional key into a hard error, and its error message loses
  the key path. Either return defaults (`get_config("bindings", "prefix")`
  merging user config over defaults) or include the full path in the error.
- **Auto-persist state.** Save/restore currently requires manual hotkeys
  (`cmd+shift+-` / `cmd+shift+=`), and stale-state cleanup only happens on
  save. Consider persisting on `hs.shutdownCallback` and loading in `init`,
  with `cleanup_stale_window_state` run on load instead.
- **`debug_window_filter` / alert-state display** belong in a debug submodule
  or behind the logger; they are pure diagnostics.

## Re-architecture (larger, optional)

- **Package as a real Spoon.** The module already calls itself `wm.spoon` and
  follows the Spoon shape (`obj`, `init`). Converting it to
  `Spoons/WindowManager.spoon` with `bindHotkeys(mapping)` per the Spoon API
  would make bindings fully user-configurable and align it with the existing
  SpoonInstall-based plugin loading.
- **Model layouts as data, not parallel tables.** Today a "layout" is an array
  of geometries, with per-window indices stored separately keyed by layout
  number. Layout numbers are implicit array positions, so reordering
  `wm.config.layouts` in `init.lua` silently invalidates saved state. Giving
  layouts stable names (`{ name = "split", geometries = {...} }`) fixes
  persistence and enables an `hs.chooser`-based layout picker.
- **Multi-monitor support** (the file's open TODO): key state by
  `screen:getUUID()` in addition to window id, apply `moveToUnit` relative to
  the window's current screen (it already is), and add per-screen layout
  selection. The stable-name change above is a prerequisite for sane
  persistence here.
- **Event model:** consider reacting to `windowFocused` (as the existing
  comment suggests) or `hs.application.watcher` instead of an unrestricted
  window filter, which is the most expensive watcher Hammerspoon offers.

## Testing

`next_index_circular`, `should_ignore_window`'s matching logic, the state
get/set/cleanup functions, and the JSON key round trip are pure or nearly
pure — ideal for the existing `tests/` + `make test` harness. A
`tests/test_window_state.lua` covering:

1. circular traversal (both directions, single-element, large steps),
2. save → load round trip preserving numeric layout keys,
3. stale-window cleanup,
4. ignore-list matching,

would lock in behavior before any of the refactors above.

## Suggested order of attack

1. Quick wins + bug fixes (JSON keys, `load_state` guard, `moveToScreen`,
   shared manageability predicate) — small diffs, immediate payoff.
2. Tests for the pure logic.
3. Logger + performance items (deferred filter, cached AX/app-name lookups).
4. Module split.
5. Spoon conversion / named layouts / multi-monitor, only if the feature is
   actually wanted.
