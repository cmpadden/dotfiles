#!/bin/env python3

"""
Unnecessary script to restore configuration files via `stow`
"""

import os
import shutil
import signal
import subprocess
import sys


def signal_handler(signal, frame):
    """
    Gracefully handle SIGTERM
    :param signal:
    :param frame:
    """
    print("\nYou've aborted the restoration process!")
    sys.exit(0)


def print_header(message, width):
    """
    Print an obnoxious header that takes the entire terminal width
    :param width: number of header columns
    """
    print("-" * cols)
    padding = int((cols - len(message)) / 2)
    print(' ' * padding + message.upper() + ' ' * padding)
    print("-" * cols)


def stow_files(folder, target):
    """
    Restore configuration files using the `stow` command.
    :param folder: folder containing configuration files
    :param target: destination folder for configuration files
    """
    process = subprocess.run(["stow", "-t", target, folder])
    if process.stdout:
        print(process.stdout)
    if process.stderr:
        print(process.stderr)


if __name__ == "__main__":

    signal.signal(signal.SIGINT, signal_handler)

    cols, lines = shutil.get_terminal_size()

    message = "restoring stowed configuration files"
    print_header(message, cols)

    target = os.path.expanduser("~")

    for f in sorted(os.listdir()):
        if os.path.isdir(f) and not f.startswith('.'):
            print("{:<10} (y/N)".format(f), end=' ')
            if input().lower().startswith("y"):
                print("Restoring...")
                stow_files(f, target)
            else:
                print("Skipping...")
            print("-" * cols)
