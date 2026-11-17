# Changelog

## [0.1.1] - 2026-11-17

- Validate against Pi 1.5.2 and add opt-in real CLI 1.3.1 metadata/help contract checks without GUI actions.
- Update the external agent-desktop CLI reference/install recommendation to 1.3.1 (unchanged 2.6 envelope).
- Scope desktop commands to `pi-<Pi session ID>` instead of a fixed `pi` namespace.
- Enable a labeled presentation-only cursor overlay lazily, without changing headless delivery.
- Warn if cursor rendering is unavailable and disable the overlay on reload/shutdown.

## [0.1.0]

Initial release of the desktop accessibility extension.

- Add a typed `desktop` tool backed by the external agent-desktop CLI.
- Support app/window discovery, snapshots, ref actions, text input, and screenshots.
- Serialize calls and bound subprocess time, output, and screenshot sizes.
- Isolate temporary CLI state and clean it up on reload/shutdown.
- Package TypeScript sources directly with an explicit Pi manifest and publish allowlist.
- Add standalone tests and type-checking, without model calls or live GUI access.
