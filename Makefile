.PHONY: help

help:
	@echo "restore   - Restore configuration files via \`stow\`"
	@echo "install   - Install platform-dependant packages and dependencies"
	@echo "configure - Set system-wide configurations and settings"

restore:
	./_restore.sh

install:
	./_install.sh

configure:
	./_configure.sh
