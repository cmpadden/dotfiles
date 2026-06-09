.PHONY: help lint

help:
	@echo "restore   - Restore configuration files via \`stow\`"
	@echo "install   - Install platform-dependant packages and dependencies"
	@echo "configure - Set system-wide configurations and settings"
	@echo "lint      - Run pre-commit checks across the repository"

lint:
	pre-commit run --all-files

restore:
	./_restore.sh

install:
	./_install.sh

configure:
	./_configure.sh
