# Changelog

## [0.1.0]

Initial standalone package for the existing delegate extension.

- Preserve the `delegate` tool, model/settings resolution, three-child FIFO queue,
  streamed results, cancellation, trust handling, and compact tool rendering.
- Include optional tmux monitors and their dependency-free viewer in the package.
- Load TypeScript directly through an explicit Pi manifest, without a build step
  or bundled Pi host dependencies.
- Add package-local tests, type-checking, a development lockfile, and an explicit
  npm tarball allowlist.
