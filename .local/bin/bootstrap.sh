#!/bin/bash

########################################
# Initial Setup
########################################

set -e
set -u
cd "$(dirname "$0")/../.."

########################################
# Global Variables
########################################


# Distribution name is used to determine valid package manager
DIST=$(lsb_release -si)

# Location of stowed folders (avoid symlinks)
ROOT=$(pwd -P)


########################################
# Pretty Printing
########################################

function info ()  {
  printf "\r [ \033[38;5;32mINFO\033[0m ] $1\n"
}

function ask ()  {
  printf "\r [ \033[38;5;226m(y/n)\033[0m ] $1\n"

  # Read the key pressed, and return true (0) if key is y, or Y
  read -n1 -r key
  if [[ "${key,}" = "y" ]]; then
    return 0
  else
    return 1
  fi
}

function succ () {
  printf "\r [ \033[38;5;40mSUCC\033[0m ] $1\n"
}

function fail () {
  printf "\r [ \033[38;5;160mFAIL\033[0m ] $1\n"
  exit
}


########################################
# General Functions
########################################

function printBasicInfo () {
	info "Distribution: ${DIST}"
	info "Dotfile Location: ${ROOT}"
}


function checkIfInstalled () {
  #echo "Cool"
  return 0
}

# Iterate over the folders in the root dotfile directory, and
# performed desired actions on the stow folders
function iterateStowFolders () {

	# Get folders in root directory that are not hidden
	for i in $(find . -maxdepth 1 -type d \( ! -iname ".*" \))
	do
    
    if ask "Restore ${i} ?"; then

      # TODO : check if program is installed, and install if not
      # TODO : verify that the package has already been restored?
      stow "${i}"
    fi
	done
	
}

########################################
# Do Things
########################################

printBasicInfo
iterateStowFolders
