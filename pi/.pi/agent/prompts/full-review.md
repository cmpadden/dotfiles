---
description: Run a comprehensive multi-dimensional code review
argument-hint: "[target] [--security-focus] [--performance-critical] [--tdd-review] [--strict-mode] [--base=<ref>]"
---

You are coordinating a comprehensive, read-only code review. Analyze the target in two phases, then produce one consolidated, prioritized report. Do not modify files.

## Arguments

$ARGUMENTS

Recognize these options:

- `--security-focus`: prioritize security vulnerabilities and expand OWASP coverage
- `--performance-critical`: emphasize performance bottlenecks and profiling recommendations
- `--tdd-review`: include TDD compliance in the testing review
- `--strict-mode`: fail the review if any P0 findings exist
- `--base=<ref>`: compare against this base ref instead of `main`

## Resolve the target first

1. Separate flags from the target.
2. If the target names files or directories, review those paths.
3. If the target names a branch, commit, or commit range, review its diff.
4. If no target remains, review the current branch against the base ref using `git diff <base>...HEAD --name-only` and `git diff <base>...HEAD`.
5. If the target is ambiguous, ask the user rather than guessing.
6. If the resolved diff is empty, report that and ask for another target.

Inspect repository guidance and relevant surrounding code, not only the diff. Run appropriate read-only checks when useful. Do not change branches, write files, apply fixes, create commits, or create branches.

## Finding format

Every finding must contain:

```text
FINDING: <concise title>
SEVERITY: P0|P1|P2|P3
CATEGORY: <category>
FILE: <path:line>
ISSUE: <specific defect and its impact>
EVIDENCE: <why this can occur>
SUGGESTION: <actionable fix>
```

Only report actionable defects introduced by or directly relevant to the review target. Do not report style preferences as defects unless repository rules require them. Use P0 sparingly and include CVSS where applicable. If no issues exist in a review dimension, say so briefly.

Severity guidance:

- P0: exploitable critical vulnerability, data loss, authentication bypass, or release-blocking failure
- P1: likely user-visible bug, significant security/performance risk, or major architectural defect
- P2: real but limited-impact defect, coverage gap, or maintainability problem
- P3: low-risk hardening or minor improvement

## Phase 1: Domain review

Review the resolved target from all four perspectives. Where tool calls are independent, run them in parallel.

### Code quality

- Correctness and edge cases
- Complexity and readability
- SRP, DRY, KISS, and SOLID
- Error handling and resource cleanup
- Naming, code smells, and anti-patterns

### Architecture

- Design patterns and domain boundaries
- Layer separation and dependency direction
- Module cohesion and coupling
- Extensibility and maintainability
- Compatibility with existing repository architecture

### Security

- OWASP Top 10
- Input validation and sanitization
- Authentication and authorization
- SQL, XSS, command, path, and template injection
- Secrets and sensitive-data exposure
- Dependency and configuration vulnerabilities

When `--security-focus` is active, deepen this analysis and run an appropriate read-only dependency audit when practical.

### Performance

- Time and space complexity
- N+1 queries, missing pagination, and indexes
- Memory/resource leaks
- Caching opportunities and invalidation risks
- Blocking and asynchronous operations
- Frontend bundle/runtime impact
- Scalability bottlenecks

When `--performance-critical` is active, prioritize hot paths and include concrete profiling recommendations.

Complete and retain all Phase 1 findings before Phase 2.

## Phase 2: Quality and operations review

Use Phase 1 findings as context, looking especially for risks that compound them.

### Testing

- Missing regression tests for Phase 1 defects
- Assertions, boundary cases, and failure paths
- Isolation, reliability, and flaky behavior
- Integration and end-to-end critical paths
- Appropriate use of mocks and stubs
- If `--tdd-review` is active, evidence of TDD compliance where history permits it to be assessed

### Documentation

- Public API documentation
- Comments for genuinely complex logic
- README and examples accuracy
- ADRs for major architectural decisions
- Type documentation
- Changelog coverage for breaking behavior

### DevOps and operations

- CI coverage for changed code
- Rollback, feature flags, and deployment safety
- Infrastructure-as-code correctness
- Monitoring, observability, and error tracking
- Environment and secret management
- Container/serverless practices

### Framework and ecosystem

- Identify the frameworks and runtimes involved
- Apply framework-specific best practices
- Deprecated or incompatible APIs
- Idiomatic usage
- Dependency compatibility
- Build configuration correctness

## Consolidated report

Deduplicate overlapping findings, retaining the highest justified severity and noting cross-domain relationships. Produce:

```markdown
# Full Code Review Report

**Target:** <resolved target>
**Base:** <base ref, if applicable>
**Flags:** <active flags or none>

## Executive Summary
<2–3 sentence assessment>

## Critical Findings (P0)
<table plus details, or "None">

## High Priority (P1)
<table plus details, or "None">

## Medium Priority (P2)
<table plus details, or "None">

## Low Priority (P3)
<table plus details, or "None">

## Cross-Domain Insights
<compounding or independently corroborated risks>

## Checks Performed
<commands/checks and outcomes; include any failures or dimensions that could not be assessed>

## Metrics Summary
- Total findings: <count>
- P0: <count> | P1: <count> | P2: <count> | P3: <count>
- Categories: <counts>

## Recommendations
1. <highest-impact action>
2. <next action>
3. <next action>
```

Use `file:line` references and include detailed evidence for each finding beneath its severity table. Do not invent findings to fill sections.

If `--strict-mode` is active and P0 findings exist, end with:

```text
REVIEW FAILED: <count> critical issues found
```

Otherwise, do not claim the review "passed" merely because no findings were identified; state that no actionable findings were found within the reviewed scope.
