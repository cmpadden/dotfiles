# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development Commands
- **Test**: `make test` - Run all test suites for the alert system
- **Format**: `make format` - Format Lua code using stylua (config at `../../.stylua.toml`)
- **Reload Configuration**: Hammerspoon automatically reloads on file changes via ReloadConfiguration spoon

### Hammerspoon CLI Commands
- **Run specific test**: `hs -c "dofile(hs.configdir .. '/tests/test_basic_alerts.lua').run()"`
- **Debug active alerts**: `hs -c "require('modules.helpers'):debug_active_alerts()"`
- **Manual config reload**: `hs -c "hs.reload()"`
- **Read console output**: `hs -c 'print(hs.console.getConsole())'`
- **Read recent console**: `hs -c 'print(hs.console.getConsole())' | tail -10`

### CLI Development Tips
- **Module reloading**: After editing Lua files, always run `hs -c "hs.reload()"` to reload the configuration
- **IPC errors are normal**: When reloading, you may see "message port was invalidated" errors - these are expected
- **Testing modules**: Use `local wm = require('modules.wm'); wm:alert_window_state()` pattern for testing
- **Crash recovery**: If `hs` command crashes with NSDestinationInvalidException, the operation may still succeed
- **Print statements**: Debug prints may fail due to IPC issues during reload, but the actual code execution continues
- **Window access**: `hs.window.allWindows()` may return windows that fail `isValid()` checks - use `pcall()` for safety

## Architecture Overview

This is a Hammerspoon configuration focused on window management and system automation with a custom alert system.

### Core Components

**Window management system (`modules/wm/`)**
- Sophisticated tiling window manager with 5 predefined layouts
- Split into submodules: `init.lua` (config/bindings/lifecycle), `geometry.lua` (built-in unit rects), `state.lua` (persistent per-layout window state), `actions.lua` (window operations), `util.lua` (pure helpers)
- Persistent state management with JSON serialization (`~/.hammerspoon/_wm.spoon.state.json`), auto-saved on shutdown/reload and restored on init
- Per-application window geometry tracking across layouts
- Built-in geometries: full, padded (left/right/center), skinny, PiP positions
- Handles Firefox AX compatibility issues by disabling `AXEnhancedUserInterface` (cached per application)
- Diagnostics use `hs.logger` (`wm.log`); raise the level with `require('modules.wm').log.setLogLevel('debug')`

**Alert system (`modules/helpers.lua`)**
- Canvas-based alert system with gradient backgrounds and animations
- Four styled alert types: info, success, warn, error
- Auto-stacking of multiple alerts with proper vertical spacing
- Asset management for icons (heroicons)
- String manipulation utilities (center, lpad, rpad)

**Plugin management (`modules/plugins.lua`)**
- Spoon ecosystem integration (ReloadConfiguration, LookupSelection, AppLauncher, KSheet, Seal)
- Application launcher with custom search paths
- Seal plugin with calculator, screen capture, and user actions

**System utilities**
- Caffeine toggle (`modules/caffeine.lua`) - Display sleep prevention
- Path watchers (`modules/watchers.lua`) - Currently disabled Downloads monitoring

### Key Bindings

**Global Modifiers:**
- `HYPER = { "cmd", "ctrl" }`
- `HYPER_SHIFT = { "cmd", "ctrl", "shift" }`

**Window Management:**
- `Cmd+Ctrl+[1-5]`: Switch to layout 1-5
- `Cmd+Shift+h/l`: Cycle focused window through layout positions
- `Cmd+Shift+-`: Save window state
- `Cmd+Shift+=`: Restore window state
- `Cmd+Shift+/`: Show current layout state
- `Cmd+Ctrl+h/l`: Move window one screen west/east

**System Controls:**
- `Hyper+0`: Toggle Caffeine (display sleep)
- `Cmd+p`: Seal launcher
- `Hyper+d`: Dictionary lookup
- `Hyper+/`: Keyboard shortcuts reference

### State management

**Window State Persistence:**
- Layout-specific window positions stored in JSON format
- Automatic cleanup of stale window references
- Per-window geometry index tracking across multiple layouts

**Alert System:**
- Active alerts table with canvas references and timers
- Automatic positioning with collision detection
- Configurable animation duration (0.3s) and display duration (3.0s)

### Testing framework

The codebase includes a comprehensive test suite in `/tests/`:
- `test_basic_alerts.lua`: Basic alert functionality and auto-dismissal
- `test_stacking.lua`: Multiple alert stacking behavior
- `test_manual_dismissal.lua`: Manual dismissal functionality
- `test_compatibility.lua`: Legacy compatibility testing
- `test_window_state.lua`: Window manager state persistence and pure-logic tests

### Configuration notes

- Animation duration set to 0 for instant window movements
- Frame correction disabled by default (slow path; the AX fix covers Firefox), opt back in with `wm.config.set_frame_correctness = true`
- Standard window detection prevents resizing of modal dialogs and floating windows
- Asset loading from `/assets/heroicons-*` directories with PNG icons
