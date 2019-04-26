#!/usr/bin/env python3

from shutil import which
from sys import exit, stderr, stdout
import subprocess

# Filtered list from `brew leaves`
packages = [
    'bash',
    'bash-completion',
    'checkstyle',
    'curl',
    'fzf',
    'htop',
    'imagemagick',
    'jq',
    'parquet-tools',
    'proselint',
    'ranger',
    'reattach-to-user-namespace',
    'screen',
    'shellcheck',
    'stow',
    'the_silver_searcher',
    'tmux',
    'unrar',
    'watch',
    'wget',
]

# Filtered list from `brew cask list -1`
casks = [
    'docker',
    'gimp',
    'google-cloud-sdk',
    'slack',
    'spectacle',
]

if __name__ == "__main__":
    if which('brew') is None:
        stderr.write('Missing dependency: brew')
        exit(1)
    else:
        pkg_process = subprocess.Popen(['brew', 'install'] + packages, stdout=subprocess.PIPE)
        out, err = pkg_process.communicate()
        if err is not None:
            exit(1)

        pkg_process = subprocess.Popen(['brew', 'cask', 'install'] + casks, stdout=subprocess.PIPE)
        out, err = pkg_process.communicate()
        if err is not None:
            exit(1)
