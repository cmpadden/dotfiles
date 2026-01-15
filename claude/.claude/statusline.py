#!/usr/bin/env python3

import json
import os
import subprocess
import sys


def get_git_branch(current_dir):
    """Get current git branch if in a git repository."""
    try:
        result = subprocess.run(
            ["git", "-C", current_dir, "branch", "--show-current"],
            capture_output=True,
            text=True,
            timeout=1
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def get_git_status(current_dir):
    """Check if there are uncommitted changes."""
    try:
        result = subprocess.run(
            ["git", "-C", current_dir, "status", "--porcelain"],
            capture_output=True,
            text=True,
            timeout=1
        )
        if result.returncode == 0:
            return "?" if result.stdout.strip() else ""
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return ""


def main():
    try:
        # Read JSON input from stdin
        data = json.load(sys.stdin)

        # Debug: log the model object to see what's available
        # Uncomment to debug:
        # with open("/tmp/claude-statusline-debug.log", "w") as f:
        #     json.dump(data.get("model", {}), f, indent=2)

        # Parse fields with defaults
        model = data.get("model", {}).get("display_name", "Claude")
        current_dir = data.get("workspace", {}).get("current_dir", "")
        dir_name = os.path.basename(current_dir) if current_dir else "~"

        # Get git info
        git_branch = get_git_branch(current_dir)
        git_status = get_git_status(current_dir) if git_branch else ""

        # Calculate context usage
        context_window = data.get("context_window", {})
        context_size = context_window.get("context_window_size", 200000)
        usage = context_window.get("current_usage")

        percent = 0
        if usage:
            input_tokens = usage.get("input_tokens", 0)
            cache_create = usage.get("cache_creation_input_tokens", 0)
            cache_read = usage.get("cache_read_input_tokens", 0)
            total_tokens = input_tokens + cache_create + cache_read
            percent = int((total_tokens * 100) / context_size)

        # Color definitions - Gruvbox theme colors
        # Using RGB escape codes for precise color matching with gruvbox.nvim
        # Format: \033[48;2;R;G;Bm for background, \033[38;2;R;G;Bm for foreground

        # Gruvbox dark background for text
        DARK0 = "40;35;33"  # #282828 - main dark background

        # Gruvbox accent colors with dark0 text
        PURPLE_BG = f"\033[48;2;211;134;155;38;2;{DARK0}m"  # #d3869b purple bg, dark text
        ORANGE_BG = f"\033[48;2;254;128;25;38;2;{DARK0}m"   # #fe8019 orange bg, dark text
        YELLOW_BG = f"\033[48;2;250;189;47;38;2;{DARK0}m"   # #fabd2f yellow bg, dark text
        GREEN_BG = f"\033[48;2;184;187;38;38;2;{DARK0}m"    # #b8bb26 green bg, dark text
        BLUE_BG = f"\033[48;2;131;165;152;38;2;{DARK0}m"    # #83a598 blue bg, dark text
        AQUA_BG = f"\033[48;2;142;192;124;38;2;{DARK0}m"    # #8ec07c aqua bg, dark text
        RED_BG = f"\033[48;2;251;73;52;38;2;{DARK0}m"       # #fb4934 red bg, dark text

        RESET = "\033[0m"

        # Build segments with Gruvbox colors
        segments = []

        # Segment 1: Model (gruvbox purple)
        segments.append(f"{PURPLE_BG} {model} {RESET}")

        # Segment 2: Directory (gruvbox blue)
        segments.append(f"{BLUE_BG} {dir_name} {RESET}")

        # Segment 3: Git branch (gruvbox yellow) - only if in git repo
        if git_branch:
            git_text = f"{git_branch}{git_status}".strip()
            segments.append(f"{YELLOW_BG} \uf418 {git_text} {RESET}")

        # Segment 4: Context usage (aqua for normal, red for high usage)
        if percent >= 80:
            segments.append(f"{RED_BG} {percent}% {RESET}")
        else:
            segments.append(f"{AQUA_BG} {percent}% {RESET}")

        # Join segments without spaces between them
        status_line = "".join(segments)

        # Just output the segments with no padding
        print(status_line, flush=True)

    except Exception:
        # Silently fail - don't output errors to statusline
        pass


if __name__ == "__main__":
    main()
