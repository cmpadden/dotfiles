#!/usr/bin/env bash

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# do not allow `pip intall` outside of virtual environments
export PIP_REQUIRE_VIRTUALENV=true
