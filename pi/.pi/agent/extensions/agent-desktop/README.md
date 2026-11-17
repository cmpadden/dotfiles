# Pi agent desktop

A deliberately small Pi extension for operating native apps through
[Vercel's agent-desktop CLI](https://github.com/vercel-labs/agent-desktop).
We own the Pi adapter, not the native accessibility implementation. This is not
a desktop chat client or a fork of the published Pi extension.

Package: `@colton.padden/pi-agent-desktop`, under the
[`colton.padden` npm user scope](https://www.npmjs.com/~colton.padden).

## Setup

Install the CLI separately; the extension never downloads or installs anything:

```sh
npm install -g agent-desktop@1.3.1
agent-desktop status
agent-desktop permissions --guide
```

The reference version is **1.3.1 CLI / 2.6 JSON envelope**, updated from 1.3.0.
[Upstream 1.3.1](https://github.com/vercel-labs/agent-desktop/compare/v1.3.0...v1.3.1)
fixes macOS sandbox lifetime and updates Linux's rustix dependency for a security
advisory; it does not change the adapter's commands or cursor-overlay API.
The adapter typechecks and its loader integration tests pass against **Pi 1.5.2**.
An opt-in contract test also checks the real macOS arm64 **1.3.1** binary's version
and 2.6 envelope, plus command/overlay flags through `--help`, without operating
apps. This is not end-to-end GUI validation: Slack screenshots/navigation were
exercised with 1.3.0; cursor rendering reported unavailable. Other CLI versions
are not blocked, but may change behavior or payloads. If npm's
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
JavaScript escape hatch. Its namespace is `pi-<Pi session ID>`, obtained from Pi's
session manager rather than inherited shell state.

On the first valid tool call, the extension enables a **presentation-only cursor
overlay**, labeled with that namespace. It does not enable physical input or take
focus: actions remain headless unless explicitly given `headed: true`. Cursor
setup is best-effort (with a separate 5-second deadline); unsupported or unavailable
renderers produce a warning without blocking desktop commands. Setup is attempted
once per runtime; `/reload` retries it. Shutdown/reload attempts to disable the
overlay before deleting private state. No multi-agent mode or concurrent desktop
delegation is enabled.

Available operations:

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
- Each instance uses a private temporary `AGENT_DESKTOP_HOME` and explicit
  `pi-<Pi session ID>` namespace. Inherited agent/session identities are removed.
  Separate Pi sessions get separate cursor overlays and snapshot namespaces, not
  separate OS pointers or desktops. Snapshot refs do not
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
screenshots, truncation/cleanup, serialization/cancellation, cursor setup/failure/
shutdown, Pi session namespacing, subprocess limits,
real Pi subfolder-manifest discovery, and the npm tarball allowlist. Integration
tests resolve the loader from the pinned development dependency. No model
requests, installed desktop CLI, permissions, or live GUI interaction required
for the default suite. The real-CLI contract test is skipped unless explicitly
configured; it only runs metadata/help commands, not desktop actions:

```sh
PI_AGENT_DESKTOP_TEST_BIN=/absolute/path/to/agent-desktop npm run check
```

Install/download the reference CLI separately; this test never installs it or
changes your global CLI. It asserts CLI 1.3.1 / envelope 2.6 so a future reference
upgrade requires an explicit compatibility review.
The fake executable fixture currently targets macOS/Linux.

For an opt-in macOS smoke test after installation: `/reload`, ask Pi to check
`desktop status`, list an already-open TextEdit window, snapshot/read it, and
request a screenshot. Test mutation only in a disposable document; verify the
result and check that the default headless call did not steal focus.

## Publishing

Publication is manual; no release or publish automation is set up.
`publishConfig.access` is set to `public`, and `npm publish` runs the checks through
`prepack`. No compilation step is required.

Before a release:

1. Confirm `npm whoami` reports `colton.padden` and the version is available.
2. Validate the external CLI on real desktop workflows and document compatibility;
   the current validation limits are described above.
3. Choose an unused version and update `CHANGELOG.md`. npm versions cannot be
   overwritten with different contents.
4. Run the following commands from this directory, reviewing the dry-run output
   before the final publish command:

   ```sh
   npm ci --ignore-scripts
   npm run check
   npm publish --dry-run
   npm publish --access public
   ```

Audit the package contents for secrets and runtime state before publishing. Only
`src/`, `CHANGELOG.md`, and npm's automatically included README, license, and
manifest belong in the tarball. Tests, tooling, installed packages, and the
development lockfile are not shipped.

After publication, install the matching version with Pi, for example:

```sh
pi install npm:@colton.padden/pi-agent-desktop@0.1.1
```

Published code is TypeScript loaded directly by Pi. The package does not bundle
Pi, TypeBox, or native desktop binaries, and does not run installer/prepare hooks.
