---
description: Rebase a branch or PR onto latest main
argument-hint: "[pull request]"
---
Require a clean worktree. Fetch `origin/main`; if `$ARGUMENTS` is set, run `gh pr checkout $ARGUMENTS`; then rebase the checked-out non-main branch onto `origin/main`. Resolve conflicts when confident; otherwise stop and report them. Do not stash, abort, or push.
