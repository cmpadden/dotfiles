# Pi delegate

`@colton.padden/pi-delegate`: fresh Pi children, streamed results, up to three
concurrent runs per session. Extra calls queue; every call waits for completion.

## Setup

Requires Node.js 24+ and Pi. The package is tested against Pi 1.5.0. It reuses the
running Pi executable and its configured providers/credentials, not a separately
bundled agent. tmux is optional and needed only for visible monitors; the viewer
uses Node.js (or the current Node/Bun runtime).

In this Stow-managed checkout, run `stow -t "$HOME" pi` from the repository root
if needed, then `/reload`. Pi discovers `delegate/package.json`, which loads
`src/index.ts`. No shim, build step, or settings changes are required.

The directory is also a standalone local Pi package:

```sh
pi install /absolute/path/to/delegate
```

After publication, it can be installed from npm:

```sh
pi install npm:@colton.padden/pi-delegate@0.1.0
```

Use one loading method; do not install a second copy alongside the
Stow-discovered extension. Pi supplies the extension's host APIs, TUI components,
and TypeBox as peers. Runtime code has no other npm dependencies, and `wt` is not
automatically invoked or installed.

## Settings

`~/.pi/agent/settings.json` (project overrides apply):

```json
{
  "pi-delegate": {
    "model": "vercel-ai-gateway/openai/gpt-6.1-sol",
    "display": "tmux"
  }
}
```

Run `/reload` after changes. No environment variable needed.

## Use

```ts
delegate({
  label: "Review caching",
  task: "Inspect caching. Report risks and suggested fixes. Do not edit files.",
  tools: ["read", "grep", "find", "ls"],
})
```

| Argument | Default / behavior |
| --- | --- |
| `task` | Required; include context, permissions, and expected output |
| `label` | Short action + target, up to 80 characters; otherwise task preview |
| `model` | Explicit override → `pi-delegate.model` → parent model |
| `thinking` | Parent's level, clamped to model capabilities |
| `cwd` | Parent cwd; must be an existing directory |
| `tools` | `read,bash,edit,write`; also accepts `grep,find,ls` |

Model IDs must include the provider: `vercel-ai-gateway/openai/gpt-6.1-sol`, not `openai/gpt-6.1-sol` for gateway access. Invalid models fail without fallback. Find IDs with `pi --list-models`.

## Display

- `"tmux"`: read-only monitors stacked to Pi's right, balanced within one row; focus and unrelated panes stay unchanged.
- `"hidden"`, omitted, or invalid: no monitors.
- Missing tmux or insufficient space: warn and continue hidden.
- Monitors close on completion/cancellation. Closing one manually does **not** cancel its child; cancel in Pi.
- Ctrl+O expands parent tool rows for full details and output.

## Isolation and limits

- Children receive the task, not the parent conversation. Normal context files and skills remain available.
- Credentials/environment are inherited; extensions, MCP, and prompt templates are disabled. Parent-only providers/auth and permission hooks are not transferred. **Not a sandbox.**
- For concurrent writers, prepare separate worktrees with `wt`, then pass distinct `cwd` paths. No automatic worktree creation, cleanup, or merging. New worktrees do not include uncommitted changes.
- Avoid parent/sibling writes or branch changes in a child's checkout. Bash can write even without `edit`/`write`.
- Project trust is inherited only for the same canonical cwd; other directories use `--no-approve`.
- Launch independent calls in one parallel tool batch. A sequential tool in that batch forces sequential execution.
- Cancellation/reload/shutdown stops children; force-killing Pi may bypass cleanup. No durable background jobs or recursive delegation.
- Results cap at 50 KiB/2,000 lines; overflow files are retained in private temporary storage. Monitor snapshots are bounded and removed after use.

## Package layout and development

```text
delegate/
├── package.json
├── package-lock.json
├── tsconfig.json
├── README.md
├── LICENSE
├── CHANGELOG.md
├── src/
│   ├── index.ts
│   ├── runtime.ts
│   ├── queue.ts
│   ├── monitor.ts
│   └── monitor-view.mjs
└── tests/
    ├── index.test.mjs
    ├── runtime.test.ts
    ├── monitor.test.ts
    └── package.test.mjs
```

From this directory, with Node.js 24+ and npm:

```sh
npm ci --ignore-scripts
npm run check          # type-check, then tests
npm pack --dry-run     # runs checks and previews the publish allowlist
```

The same commands work after copying this directory out of dotfiles. There is
no dependency on the managed Pi installation path, a global Pi executable, or
repository-root configuration. Development dependencies provide a pinned Pi host,
its API/TUI packages, TypeBox, TypeScript, and Node types; none are bundled in the
published package. Dependencies and generated package archives are gitignored.

Tests use local fake children; no model requests, credentials, or paid API calls.
They exercise Pi manifest discovery, queueing, cancellation, usage accounting,
trust handling, rendering, monitor cleanup, and the npm tarball allowlist. The
integration tests resolve Pi's internal loader from the pinned development host.
Real tmux tests use an isolated server and skip if tmux is unavailable. The viewer
stays a dependency-free `.mjs` file so tmux can launch it directly with Node.

## Publishing

Publication is manual; nothing publishes automatically. From this directory:

1. Confirm `npm whoami` reports `colton.padden` and the intended version is unused.
2. Update the version and `CHANGELOG.md` for the release.
3. Run `npm ci --ignore-scripts`, `npm run check`, then `npm publish --dry-run`.
4. Audit the package contents for secrets and runtime state. Only the five files
   in `src/`, `CHANGELOG.md`, and npm's automatically included README, license,
   and manifest belong in the tarball. The monitor viewer must be included.
5. When ready, publish explicitly with `npm publish --access public`.

Pi loads the TypeScript sources directly; no compilation or installer/prepare
hook is needed. `prepack` runs the checks before packing or publishing. Keep host
packages in peer/development dependencies, never runtime dependencies. npm
versions cannot be overwritten with different contents.

## License

MIT. The subprocess lifecycle is adapted from Pi's
[MIT-licensed subagent example](https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent).
The license retains Mario Zechner's upstream copyright notice.
