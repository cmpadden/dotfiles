# Contributor Guide

## Repository structure

This is a GNU Stow-managed dotfiles repository. Each top-level configuration directory is a Stow package: its contents mirror their destination paths under `$HOME`. Directories prefixed with `_` are archives, not active Stow packages. Preserve that layout when adding or moving configuration.

## Generated and runtime state

Do not commit generated or machine-specific state. This includes credentials, session history, caches, and installed dependencies such as `node_modules`. Add new runtime paths to `.gitignore`; retain declarative configuration and dependency manifests needed to reproduce the setup.

## Validation and formatting

Pre-commit owns repository validation and formatting checks. Before submitting changes, run:

```sh
make lint    # pre-commit run --all-files
make format  # format shell, Lua, and Python files
```

Pre-commit checks YAML, whitespace, secrets, Ghostty configuration, shell syntax and formatting, Lua formatting, and Python formatting, linting, and type checking.

Before committing, audit the staged diff for credentials, tokens, private URLs, machine-specific state, and other sensitive information. Do not rely solely on automated secret detection.

## Commits

Prefer commit subjects in the form `<scope>: <imperative summary>`. Use the affected tool or package as the scope for its configuration changes. Use `chore` for repository-level maintenance, such as contributor guidance, CI, or repository metadata. For example:

```text
pi: ignore npm node_modules
ghostty: restore menu bar on macos
chore: add contributor guide
```
