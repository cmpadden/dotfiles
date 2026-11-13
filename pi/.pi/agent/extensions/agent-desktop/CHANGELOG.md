# Changelog

## [0.1.0]

Initial local prototype; not published to npm.

- Add a typed `desktop` tool backed by the external agent-desktop CLI.
- Support app/window discovery, snapshots, ref actions, text input, and screenshots.
- Serialize calls and bound subprocess time, output, and screenshot sizes.
- Isolate temporary CLI state and clean it up on reload/shutdown.
- Package TypeScript sources directly with an explicit Pi manifest and publish allowlist.
- Add standalone tests and type-checking, without model calls or live GUI access.
