SHELL_FILES := $(shell git ls-files '*.bash' '*.sh' 'direnv/.config/direnv/direnvrc')
LUA_FILES := $(shell git ls-files '*.lua')
PYTHON_FILES := $(shell git ls-files '*.py')

.PHONY: help lint format format-sh format-lua format-python

help:
	@echo "restore       - Restore configuration files via \`stow\`"
	@echo "install       - Install platform-dependant packages and dependencies"
	@echo "configure     - Set system-wide configurations and settings"
	@echo "lint          - Run pre-commit checks across the repository"
	@echo "format        - Format shell, Lua, and Python files"
	@echo "format-sh     - Format shell files with shfmt"
	@echo "format-lua    - Format Lua files with stylua"
	@echo "format-python - Format Python files with ruff"

lint:
	pre-commit run --all-files

format: format-sh format-lua format-python

format-sh:
	shfmt -w -i 4 $(SHELL_FILES)

format-lua:
	stylua --config-path .stylua.toml $(LUA_FILES)

format-python:
	uvx ruff format $(PYTHON_FILES)

restore:
	./_restore.sh

install:
	./_install.sh

configure:
	./_configure.sh
