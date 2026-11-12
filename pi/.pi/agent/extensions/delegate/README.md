# Delegate

Fresh Pi children, streamed results, up to three concurrent runs per session. Extra calls queue; every call waits for completion.

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

## Tests

From `pi/`, with Node.js 24+ and the managed Pi installation:

```sh
node --test .pi/agent/extensions/delegate/{runtime.test.ts,index.test.mjs,monitor.test.ts}
```

Local fake children; no paid requests. Real tmux tests use an isolated server and skip if tmux is unavailable.
