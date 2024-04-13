"""Daily git activity visualizations.

USAGE

    python .github/daily-git-stats.py >> .github/stats.txt

ENHANCEMENTS

 - Generate a heatmap (eg. `calplot`)
 - Embed statistics in README
 - Trigger stat generation on pre-commit hook

"""

import re
import subprocess

from typing import Generator, Tuple


def _git_daily_commits(path=".") -> Generator[Tuple[int, str], None, None]:
    command = f"git log --date=short --pretty=format:%ad {path} | sort | uniq -c"
    output = subprocess.check_output(command, shell=True, universal_newlines=True)
    pattern = r"\s*(\d+)\s*(\d{4}-\d{2}-\d{2})"
    for line in output.splitlines():
        if m := re.match(pattern, line):
            yield int(m.group(1)), m.group(2)


if __name__ == "__main__":
    for n, d in _git_daily_commits():
        print(d, "." * n)
