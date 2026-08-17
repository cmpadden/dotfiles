# Environment safe to load from login and interactive shells.
# This file is idempotent because `.bash_profile` loads `.bashrc` below.
[[ ${DOTFILES_BASH_PROFILE_LOADED:-} ]] && return
DOTFILES_BASH_PROFILE_LOADED=1
export DOTFILES_BASH_PROFILE_LOADED

export PATH="$HOME/.local/bin:$PATH"

# Do not allow `pip install` outside virtual environments.
export PIP_REQUIRE_VIRTUALENV=true
