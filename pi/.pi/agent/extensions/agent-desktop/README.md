# Pi agent desktop

A deliberately small Pi extension for operating native apps through
[Vercel's agent-desktop CLI](https://github.com/vercel-labs/agent-desktop).
We own the Pi adapter, not the native accessibility implementation. This is not
a desktop chat client or a fork of the published Pi extension.

The package is **private and unpublished**. Its name is
`@colton.padden/pi-agent-desktop`, under the
[`colton.padden` npm user scope](https://www.npmjs.com/~colton.padden).
No npm package name has been reserved.

## Setup

Install the CLI separately; the extension never downloads or installs anything:

```sh
npm install -g agent-desktop@1.3.0
agent-desktop status
agent-desktop permissions --guide
```

The adapter was written against the **1.3.0 CLI / 2.6 JSON envelope** source
contract. Tests use fake executables; real desktop behavior is not yet validated.
Other CLI versions are not blocked, but may change behavior or payloads. If npm's
`min-release-age` policy excludes the pinned release, wait for it to become
eligible rather than assuming an older CLI has the same contract.

On macOS, grant Accessibility to the terminal running Pi. Screenshots also need
Screen Recording permission. Headless means no physical pointer/focus delivery
by default, **not** no permissions or no side effects.

In the dotfiles checkout, Stow the `pi` package if needed
(`stow -t "$HOME" pi` from the repository root), then run `/reload`. Pi discovers
`~/.pi/agent/extensions/agent-desktop/package.json`, which declares `src/index.ts`.
No shim or duplicate entry point is needed.

The directory is also a standalone local Pi package:

```sh
pi install /absolute/path/to/agent-desktop
```

Use one loading method, not both the Stow-discovered extension and a separately
installed copy. No compilation step or runtime dependency installation is needed
for the extension: Pi provides TypeBox and its extension APIs as peers. The
native desktop CLI remains a separate prerequisite.

Optional environment override (set before starting Pi):

```sh
export PI_AGENT_DESKTOP_BIN=/absolute/path/to/agent-desktop
```

This is an executable path, not a shell command; flags in it are not expanded.
Missing CLI/permissions do not prevent Pi startup. No process or temporary state
is created until the first tool call. Permission errors are returned unchanged;
the extension never requests permissions itself.

## Tool

One tool named `desktop`, with explicit operations and no arbitrary argument or
JavaScript escape hatch:

| Command | Inputs |
| --- | --- |
| `status` | None |
| `list-apps`, `list-windows` | Optional `app` filter |
| `snapshot` | `app` and/or `windowId`, or `root`; optional `maxDepth`, `interactiveOnly`, `skeleton` |
| `get` | `ref`; optional `property` (`text`, `value`, `title`, `bounds`, `role`, `states`) |
| `click` | `ref` |
| `type`, `set-value` | `ref`, `text` (empty text allowed only for `set-value`) |
| `press` | `app` and/or `windowId`, `keys` such as `cmd+a` or `return` |
| `scroll` | `ref`; optional `direction` (default `down`), `amount` (default `3`) |
| `screenshot` | `app` and/or `windowId`; returns a PNG image attachment |

Mutation commands also accept `headed: true` to explicitly allow focus/cursor
side effects. There is no automatic fallback from headless to headed input.
Screenshots and keyboard input require a target; there is no implicit full-screen
capture or typing into whichever app happens to be focused.

Every command accepts `timeoutMs` (100–60000, default 15000), a **whole-process**
deadline. It does not extend the CLI's own traversal/action deadlines. An action
may already have landed when the process deadline expires: inspect the UI rather
than assuming a timeout means nothing happened.

Snapshot defaults: compact, interactive nodes only, max depth 6. Use
`interactiveOnly: false` to read static text, `skeleton: true` for a shallow map,
or `root: "@snapshot:eN"` to drill into a subtree. Preserve qualified refs exactly.
The extension does not rewrite refs or retry errors.

Example tool inputs:

```json
{"command":"status"}
{"command":"list-windows","app":"TextEdit"}
{"command":"snapshot","app":"TextEdit","interactiveOnly":false}
```

Then act on a real ref from that snapshot and verify with `get` or a new snapshot.
A successful action envelope is not necessarily proof of application-level
persistence; upstream's `disposition` and verification fields remain intact.

## Execution and privacy

- Direct subprocess invocation, no shell. Typed text is piped over stdin rather
  than exposed in process arguments. **Tool arguments/results still enter the Pi
  session and may be sent to the configured model. Do not use this for secrets.**
- Pi sequential execution plus an internal queue prevents this extension instance
  from racing its own calls. It does **not** coordinate separate Pi processes,
  external CLI calls, or a human interacting with the same desktop. Avoid
  concurrent desktop delegation. Do not batch dependent actions using refs that
  may become stale before they execute.
- Each instance uses a private temporary `AGENT_DESKTOP_HOME` and explicit session
  namespace. Inherited agent/session identities are removed. Snapshot refs do not
  survive `/reload`, new/resumed sessions, or process restarts; always resnapshot.
- Abort, deadline and output limits terminate the CLI. A cancellation cannot undo
  an already-delivered action. Upstream helpers may have their own lifecycles.
- Text output is capped at 50 KiB/2000 lines, with a truncation notice and private
  full-JSON file. Captured process output is bounded at 2 MiB (12 MiB for screenshot
  envelopes); exceeding it is an error, not a usable partial result.
- PNG attachments are limited to 8 MiB; base64 is not duplicated in result text or
  details. Screenshots are only taken when requested.
- Shutdown/reload cancels work, skips queued calls, and removes temporary state and
  overflow files. Force-killing Pi can leave `pi-agent-desktop-*` directories in the
  OS temporary directory; their contents may be sensitive. Pi's own session
  history is separate and is **not** erased by this cleanup.
- App content is untrusted data. Neither the command allowlist nor `headed` is a
  security sandbox, particularly when Pi also has Bash. Headless clicks can still
  send messages, submit forms, or delete data.

No clipboard commands, raw coordinates, shell commands, app launching, tracing,
automatic screenshots, cross-process locks, custom TUI renderer, or JS cells yet.
Add capabilities as concrete workflows need them.

## Package layout and development

```text
agent-desktop/
├── package.json
├── package-lock.json
├── tsconfig.json
├── README.md
├── LICENSE
├── CHANGELOG.md
├── src/
│   ├── index.ts
│   └── runtime.ts
└── tests/
    ├── index.test.mjs
    ├── package.test.mjs
    └── runtime.test.ts
```

From this directory, with Node.js 24+ and npm:

```sh
npm ci --ignore-scripts
npm run check          # type-check, then offline tests
npm pack --dry-run     # runs checks and previews the publish allowlist
```

These commands also work after copying this directory out of the dotfiles repo.
No managed Pi installation path, global Pi executable, build, or repository-root
configuration is required. Development dependencies include a pinned Pi host for
integration tests, TypeBox, TypeScript, and Node types. They are not bundled or
installed as runtime dependencies for consumers. Installed dependencies and
local package archives are gitignored.

Tests cover command construction, stdin/flag isolation, structured errors,
screenshots, truncation/cleanup, serialization/cancellation, subprocess limits,
real Pi subfolder-manifest discovery, and the npm tarball allowlist. Integration
tests resolve the loader from the pinned development dependency. No model
requests, installed desktop CLI, permissions, or live GUI interaction required.
The fake executable fixture currently targets macOS/Linux.

For an opt-in macOS smoke test after installation: `/reload`, ask Pi to check
`desktop status`, list an already-open TextEdit window, snapshot/read it, and
request a screenshot. Test mutation only in a disposable document; verify the
result and check that the default headless call did not steal focus.

## Before publishing

Nothing publishes automatically. `private: true` intentionally blocks npm
publication even though `publishConfig.access` is already set to `public`.

1. Confirm npm is authenticated as `colton.padden` and the package name is available.
2. Validate the external CLI on real desktop workflows and document compatibility.
3. Choose the release version, update `CHANGELOG.md`, and remove the unpublished
   wording from the README/changelog.
4. Explicitly remove `private: true` and update the private-package test to reflect
   the release decision. Re-run `npm run check`.
5. Run `npm pack --dry-run` and audit the file list/content for secrets and runtime
   state. Only `src/`, `CHANGELOG.md`, and npm's automatically included README,
   license, and manifest belong in the tarball. Tests, tooling, installed packages,
   and the development lockfile are not shipped.
6. Publish manually only when intended; no release or publish automation is set up.

Published code is TypeScript loaded directly by Pi. The package does not bundle
Pi, TypeBox, or native desktop binaries, and does not run installer/prepare hooks.
