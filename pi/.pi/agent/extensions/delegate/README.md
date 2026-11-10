# Delegate

A small foreground-only alternative to Pi's [upstream subagent example](https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent). One tool, no named agents, workflow engine, background jobs, or model-routing configuration. Delegates run concurrently (up to three per parent session), with optional working directories prepared by the parent.

## Use

This directory is auto-discovered at `~/.pi/agent/extensions/delegate/`. Run `/reload` after adding or changing it.

Ask Pi naturally:

> Use delegate with MODEL_A to plan this change without editing files. Then show me the plan before implementation.

The tool accepts:

```ts
delegate({
  task: "Inspect the caching implementation. Return a plan, relevant files, risks, and validation steps. Do not modify files.",
  model: "provider/model-id",
  thinking: "high",
  tools: ["read", "grep", "find", "ls"],
})
```

Replace `provider/model-id` with an exact ID from `pi --list-models`. Model IDs may themselves contain slashes. `model` and `task` are required; `thinking` inherits the parent's level when omitted (Pi clamps it to the child's model capabilities).

`cwd` selects an **existing directory**, defaulting to the parent's working directory. Relative paths resolve against the parent cwd; absolute paths, `~/` paths, and a leading `@` are supported. Symlinks are resolved and non-directories rejected before starting a child. The canonical path is shown in progress and final results.

`tools` defaults to `read,bash,edit,write`. The optional allowlist accepts `read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`. Use `read,grep,find,ls` for planning/review without write or shell tools. Bash can modify files even without `edit` or `write`.

For implementation, call delegate again with the implementation model and include the approved plan in the task. There is no implicit handoff or automatic planning/review policy. Keep routing preferences in `AGENTS.md` if desired; this extension does not change them.

## Choosing isolation with Worktrunk

The **parent agent decides before launching** whether isolation is needed. The extension does not classify tasks, create worktrees, switch branches, merge, or clean up worktrees.

| Task | Suggested environment |
| --- | --- |
| Read code or review without writes | Existing checkout, preferably `tools: ["read", "grep", "find", "ls"]` |
| Fix independent PRs or implement separate changes concurrently | One dedicated worktree per writer |
| Modify the parent's uncommitted work | Parent checkout, with no concurrent parent/sibling writers or branch changes |
| Run builds/tests/formatters | Usually a dedicated worktree; these commands may write files |

If uncertain, investigate read-only first. For independent PR fixes:

1. Inspect `wt list --format json` and identify the PR branches/bases. Never assume an existing worktree is free just because it exists; check with the user when ownership/activity is uncertain.
2. Prepare worktrees with `wt`, then pass the returned paths to delegate. For example, `wt switch pr:6182 --no-cd --no-hooks --format json` selects/creates the PR's worktree, while `wt switch --create fix/cache --base origin/main --no-cd --no-hooks --format json` creates a new branch from an explicit base. Inspect the JSON result rather than guessing the configured path. Do preparation in an earlier tool batch, not alongside the delegates that depend on it.
3. Choose hooks/setup deliberately: `--no-hooks` avoids interactive approval and background setup. If hooks are needed, inspect them, honor approval decisions, and await required setup; never blindly use `--yes` to approve new project commands. Dependencies and ignored files may need project-specific setup. Do not indiscriminately copy secrets/caches or share writable build outputs.
4. Launch independent delegate calls in the **same assistant tool batch** with distinct `cwd` values:

   ```ts
   delegate({ task: "Fix PR 6182 only. Commit/push only if authorized. Report changes and tests.", model: "provider/model-id", cwd: "/path/from/wt/pr-6182" })
   delegate({ task: "Fix PR 6183 only. Commit/push only if authorized. Report changes and tests.", model: "provider/model-id", cwd: "/path/from/wt/pr-6183" })
   ```

5. Review each child's report and changes. Keep worktrees with useful work, including after failures/cancellation. Cleanup is an explicit parent/user decision; do not force-remove dirty worktrees or delete unmerged branches automatically.

New worktrees contain the selected committed base, **not the parent's uncommitted changes**. Different subdirectories of one checkout are not independent worktrees. Worktrees separate working files, HEAD, and index, but still share Git refs, credentials, ports, databases, and external effects. They are not sandboxes.

## Behavior and boundaries

- Each call starts a fresh Pi process in its selected working directory. Repository/global context files and normal skill discovery remain available; the parent's conversation is **not** copied.
- The tool stays pending until the child exits. Up to **three children run concurrently per parent session**; further calls wait in a cancellable FIFO queue. This limit does not cover other Pi sessions. Pi must also be in parallel tool mode: a sequential tool anywhere in the same assistant batch makes that entire batch sequential.
- Progress is streamed by code, not model-driven polling. Each row shows queued/running/final status, canonical cwd, time spent queued, and child execution time. One-second heartbeats update timing even when the child is quiet. Queueing does not launch a child or consume model tokens.
- Parent and sibling tools can now execute alongside delegates. The parent must avoid writes, staging, branch changes, and conflicting external actions in a workspace used by a child. The extension does not enforce workspace ownership or coordinate other processes.
- The child uses the running Pi executable/version, normal configured providers, and inherited environment. Extensions, MCP, and prompt templates are disabled. Providers/authentication available **only** through parent extensions or transient parent API-key overrides are not transferred.
- The parent's current project-trust decision is passed explicitly **only when the canonical selected cwd equals the parent's canonical cwd**. Any different directory, including another worktree or subdirectory, starts with `--no-approve`; a trusted parent does not silently approve another project's dynamic configuration. Global context remains available, but project-local trust-gated resources in a new worktree are not enabled by delegation.
- Cancellation sends SIGTERM and escalates to SIGKILL after five seconds if needed. On macOS/Linux it targets the child's process group, including ordinary descendants. Reload/shutdown cancels and awaits both active and queued calls, without starting queued children. This is not durable background execution; forcibly killing the parent can bypass cleanup. Windows cancellation targets the direct child only.
- The delegate tool is unavailable in children, and child instructions prohibit further delegation or background work. This is a workflow guard, **not a sandbox**: Bash still has normal OS access and can launch programs. Deliberately detached descendants may escape process-group cleanup.
- Children share the selected checkout and inherited credentials. Isolation exists only when the parent supplies independent worktrees; there is no automatic isolation or parent permission-hook enforcement inside the child. Do not use this where disabling parent security extensions would violate your expectations.
- Only a normally stopped final text response counts as success. Provider errors, token limits, nonzero exits, invalid JSONL, and missing final responses are errors; available partial text, usage, and bounded stderr are preserved.
- Output is limited to 50 KiB/2,000 lines. Longer results are saved in a private temporary directory, with the path included in the result. These files are not automatically deleted; remove them when no longer needed. Child sessions are otherwise ephemeral (`--no-session`).
- Recent tool activity and text stream into the tool row; expand it for more output. Child model usage is returned to Pi's session accounting.

## Tests

From the `pi/` Stow package directory, with Node.js 24+ and the managed Pi installation present:

```sh
node --test .pi/agent/extensions/delegate/runtime.test.ts .pi/agent/extensions/delegate/index.test.mjs
```

Tests cover overlapping child processes and the three-child cap, queue cancellation/shutdown, cwd resolution and trust boundaries, queued/timing rendering, awaited completion, streaming, model/tool arguments, UTF-8/JSONL framing, usage, errors, truncation, recursion guards, and cancellation/shutdown. They use local fake child processes, not paid model requests. `index.test.mjs` uses the installed Pi extension loader; `runtime.test.ts` tests the process lifecycle independently.
