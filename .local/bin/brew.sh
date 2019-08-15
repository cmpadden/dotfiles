#!/usr/bin/env bash
#
# Bootstrap MacOS environment by installing favorite packages via Homebrew


PACKAGES=(
  awscli
  azure-cli
  bash
  bash-completion
  black
  checkstyle
  curl
  dante
  direnv
  exa
  fzf
  htop
  httpie
  hub
  imagemagick
  jq
  parquet-tools
  pass
  pass-otp
  pipenv
  prettier
  proselint
  ranger
  reattach-to-user-namespace
  sbt
  shellcheck
  stow
  the_silver_searcher
  tmux
  unrar
  vim
  watch
  wget
  yarn
)

CASKS=(
  google-cloud-sdk
  slack
  spectacle
)


CASKS_EXTRA=(
  gimp
  docker
)

brew update

for p in ${PACKAGES[*]}; do
    # alternatively, could use `xargs`
    brew install "$p"
done

for c in ${CASKS[*]}; do
    brew cask install "$c"
done

brew cleanup
