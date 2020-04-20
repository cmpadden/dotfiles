import os
import colors

c = c            # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

HOME = os.path.expanduser("~")
VIM = "/usr/local/bin/gvim"

c.editor.command = [
    f"{VIM}",
    "-u", "NONE",                # Do not load custom `.vimrc`
    "-f",                        # Foreground: Don't fork when starting GUI
    "{file}",
    "-c",                        # Execute <command> after loading the first file
    "normal {line}G{column0}l",  # Go to cursor location
]

# apply custom colors
colors.apply(c, scheme='light')

c.tabs.favicons.scale = 1.0
c.tabs.indicator.width = 0
c.tabs.position = "right"
c.tabs.title.format = "{audio}{index} {current_title}"
c.tabs.width = 250

c.fonts.hints = "bold 14pt monospace"
c.hints.mode = "number"
c.hints.scatter = False
c.hints.uppercase = True

# Manually edit quickmarks/bookmarks
config.bind('<e><q>', f"spawn {VIM} -u NONE {HOME}/.qutebrowser/quickmarks")
config.bind('<e><b>', f"spawn {VIM} -u NONE {HOME}/.qutebrowser/bookmarks/urls")

# Userscripts
config.bind('<z><l>', 'spawn --userscript qute-pass')
config.bind('<z><u><l>', 'spawn --userscript qute-pass --username-only')
config.bind('<z><p><l>', 'spawn --userscript qute-pass --password-only')
config.bind('<z><o><l>', 'spawn --userscript qute-pass --otp-only')


# QuteBrowser on MacOS is finicky with paths, requiring `open -a ... --args`
config.bind(
    '<Ctrl-Shift-m>',
    'hint links spawn --detach open -a mpv --args --force-window yes {hint-url}'
)
