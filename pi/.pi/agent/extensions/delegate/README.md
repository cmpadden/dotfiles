# Delegate

A small foreground-only alternative to Pi's [upstream subagent example](https://github.com/earendil-works/pi/tree/main/packages/coding-agent/examples/extensions/subagent). One tool, no named agents, workflow engine, background jobs, or model-routing configuration.

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

`tools` defaults to `read,bash,edit,write`. The optional allowlist accepts `read`, `bash`, `edit`, `write`, `grep`, `find`, and `ls`. Use `read,grep,find,ls` for planning/review without write or shell tools. Bash can modify files even without `edit` or `write`.

For implementation, call delegate again with the implementation model and include the approved plan in the task. There is no implicit handoff or automatic planning/review policy. Keep routing preferences in `AGENTS.md` if desired; this extension does not change them.

## Behavior and boundaries

- Each call starts a fresh Pi process in the parent's working directory. Repository/global context files and normal skill discovery remain available; the parent's conversation is **not** copied.
- The tool stays pending until the child exits. Progress is streamed by code, not model-driven polling. Calls execute sequentially with other parent tools to avoid concurrent checkout edits.
- The child uses the running Pi executable/version, normal configured providers, and inherited environment. Extensions, MCP, and prompt templates are disabled. Providers/authentication available **only** through parent extensions or transient parent API-key overrides are not transferred.
- The parent's current project-trust decision is passed explicitly; delegation does not silently approve an untrusted checkout.
- Cancellation sends SIGTERM and escalates to SIGKILL after five seconds if needed. On macOS/Linux it targets the child's process group, including ordinary descendants. Reload/shutdown cancels and awaits active children. This is not durable background execution; forcibly killing the parent can bypass cleanup. Windows cancellation targets the direct child only.
- The delegate tool is unavailable in children, and child instructions prohibit further delegation or background work. This is a workflow guard, **not a sandbox**: Bash still has normal OS access and can launch programs. Deliberately detached descendants may escape process-group cleanup.
- The child shares the checkout and credentials. There is no worktree isolation or parent permission-hook enforcement inside the child. Do not use this where disabling parent security extensions would violate your expectations.
- Only a normally stopped final text response counts as success. Provider errors, token limits, nonzero exits, invalid JSONL, and missing final responses are errors; available partial text, usage, and bounded stderr are preserved.
- Output is limited to 50 KiB/2,000 lines. Longer results are saved in a private temporary directory, with the path included in the result. These files are not automatically deleted; remove them when no longer needed. Child sessions are otherwise ephemeral (`--no-session`).
- Recent tool activity and text stream into the tool row; expand it for more output. Child model usage is returned to Pi's session accounting.

## Tests

From the `pi/` Stow package directory, with Node.js 24+ and the managed Pi installation present:

```sh
node --test .pi/agent/extensions/delegate/runtime.test.ts .pi/agent/extensions/delegate/index.test.mjs
```

Tests cover awaited completion, streaming, model/tool arguments, UTF-8/JSONL framing, usage, errors, truncation, recursion guards, and cancellation/shutdown. They use local fake child processes, not paid model requests. `index.test.mjs` uses the installed Pi extension loader; `runtime.test.ts` tests the process lifecycle independently.
