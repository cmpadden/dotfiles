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

## Architecture Overview

This is a Hammerspoon configuration focused on window management and system automation with a custom alert system.

### Core Components

**Window management system (`modules/window.lua`)**
- Sophisticated tiling window manager with 5 predefined layouts
- Persistent state management with JSON serialization (`~/.hammerspoon/_wm.spoon.state.json`)
- Per-application window geometry tracking across layouts
- Built-in geometries: full, padded (left/right/center), skinny, PiP positions
- Handles Firefox AX compatibility issues by disabling `AXEnhancedUserInterface`

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
- `Cmd+Ctrl+h/l`: Move window to screen 1/2

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

### Configuration notes

- Animation duration set to 0 for instant window movements
- Frame correction enabled for precise window positioning
- Standard window detection prevents resizing of modal dialogs and floating windows
- Asset loading from `/assets/heroicons-*` directories with PNG icons
