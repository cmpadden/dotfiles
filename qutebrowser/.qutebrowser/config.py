import os
import colors

c = c            # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

QUTE_PATH = os.path.dirname(os.path.realpath(__file__))
VIM = "/usr/local/bin/gvim"

# apply custom colors
colors.apply(c, scheme='dracula')

c.editor.command = [
    f"{VIM}",
    "-u", "NONE",                # Do not load custom `.vimrc`
    "-f",                        # Foreground: Don't fork when starting GUI
    "{file}",
    "-c",                        # Execute <command> after loading the first file
    "normal {line}G{column0}l",  # Go to cursor location
]

c.auto_save.interval = 60_000
c.auto_save.session = True

c.fonts.default_family = ["Lucida Console", "monospace"]
c.fonts.default_size = "12pt"
c.fonts.hints = "20pt default_family"

c.tabs.indicator.width = 0
c.tabs.position = "right"
c.tabs.title.format = "{audio}{index} {current_title}"
c.tabs.width = 250

c.hints.mode = "number"
c.hints.scatter = False
c.hints.uppercase = True

c.window.title_format ="{perc}{current_title}"

c.url.default_page = f"file:///{QUTE_PATH}/blank.html"

# Attempt at reducing fingerprint -- https://panopticlick.eff.org/
# https://github.com/lobstrio/shadow-useragent
c.content.headers.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
c.content.headers.accept_language = ""

# disable javascript, and add aliases to turn on/off
c.content.javascript.enabled = False
c.aliases['js-on'] = 'set content.javascript.enabled True'
c.aliases['js-off'] = 'set content.javascript.enabled False'

# Manually edit quickmarks/bookmarks
config.bind('<e><q>', f"spawn {VIM} -u NONE {QUTE_PATH}/quickmarks")
config.bind('<e><b>', f"spawn {VIM} -u NONE {QUTE_PATH}/bookmarks/urls")

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
