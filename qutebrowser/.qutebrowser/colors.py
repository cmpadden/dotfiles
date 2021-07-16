SCHEMES = {
    'light': {
        'background':           '#ffffff',
        'background-alt':       '#ffffff',
        'background-attention': '#181920',
        'border':               '#282a36',
        'current-line':         '#e0e0e0',
        'selection':            '#e0e0e0',
        'foreground':           '#000000',
        'foreground-alt':       '#e0e0e0',
        'foreground-attention': '#ffffff',
        'comment':              '#45454b',
        'cyan':                 '#006666',
        'green':                '#184b24',
        'orange':               '#7f5200',
        'pink':                 '#7f6065',
        'purple':               '#330033',
        'red':                  '#660000',
        'yellow':               '#4c4000'
    },
    'dark': {
        'background':           '#000000',
        'background-alt':       '#000000',
        'background-attention': '#330033',
        'border':               '#000000',
        'current-line':         '#000000',
        'selection':            '#331133',
        'foreground':           '#f8f8f2',
        'foreground-alt':       '#e0e0e0',
        'foreground-attention': '#ffffff',
        'comment':              '#6272a4',
        'cyan':                 '#8be9fd',
        'green':                '#50d070',
        'orange':               '#ffb86c',
        'pink':                 '#ff79c6',
        'purple':               '#bd93f9',
        'red':                  '#ff5555',
        'yellow':               '#f1fa8c'
    },
    'dracula': {
        'background':           '#282a36',
        'background-alt':       '#282a36',
        'background-attention': '#181920',
        'border':               '#282a36',
        'current-line':         '#44475a',
        'selection':            '#44475a',
        'foreground':           '#f8f8f2',
        'foreground-alt':       '#e0e0e0',
        'foreground-attention': '#ffffff',
        'comment':              '#6272a4',
        'cyan':                 '#8be9fd',
        'green':                '#50fa7b',
        'orange':               '#ffb86c',
        'pink':                 '#ff79c6',
        'purple':               '#bd93f9',
        'red':                  '#ff5555',
        'yellow':               '#f1fa8c'
    },
    'phd': {
        'background':           '#282a36',
        'background-alt':       '#282a36',
        'background-attention': '#181920',
        'border':               '#282a36',
        'current-line':         '#44475a',
        'selection':            '#44475a',
        'foreground':           '#f8f8f2',
        'foreground-alt':       '#e0e0e0',
        'foreground-attention': '#ffffff',
        'comment':              '#6272a4',
        'cyan':                 '#8be9fd',
        'green':                '#50fa7b',
        'orange':               '#ffb86c',
        'pink':                 '#ff79c6',
        'purple':               '#bd93f9',
        'red':                  '#ff5555',
        'yellow':               '#f1fa8c'
    },
}


def apply_base16(c):

    base00 = "#061229"
    base01 = "#2a3448"
    base02 = "#4d5666"
    base03 = "#717885"
    base04 = "#9a99a3"
    base05 = "#b8bbc2"
    base06 = "#dbdde0"
    base07 = "#ffffff"
    base08 = "#d07346"
    base09 = "#f0a000"
    base0A = "#fbd461"
    base0B = "#99bf52"
    base0C = "#72b9bf"
    base0D = "#5299bf"
    base0E = "#9989cc"
    base0F = "#b08060"

    # Text color of the completion widget. May be a single color to use for
    # all columns or a list of three colors, one for each column.
    c.colors.completion.fg = base05

    # Background color of the completion widget for odd rows.
    c.colors.completion.odd.bg = base00

    # Background color of the completion widget for even rows.
    c.colors.completion.even.bg = base00

    # Foreground color of completion widget category headers.
    c.colors.completion.category.fg = base0D

    # Background color of the completion widget category headers.
    c.colors.completion.category.bg = base00

    # Top border color of the completion widget category headers.
    c.colors.completion.category.border.top = base00

    # Bottom border color of the completion widget category headers.
    c.colors.completion.category.border.bottom = base00

    # Foreground color of the selected completion item.
    c.colors.completion.item.selected.fg = base00

    # Background color of the selected completion item.
    c.colors.completion.item.selected.bg = base0D

    # Top border color of the selected completion item
    c.colors.completion.item.selected.border.top = base0D

    # Bottom border color of the selected completion item.
    c.colors.completion.item.selected.border.bottom = base0D

    # Foreground color of the matched text in the selected completion item.
    c.colors.completion.item.selected.match.fg = base00

    # Foreground color of the matched text in the completion.
    c.colors.completion.match.fg = base09

    # Color of the scrollbar handle in the completion view.
    c.colors.completion.scrollbar.fg = base05

    # Color of the scrollbar in the completion view.
    c.colors.completion.scrollbar.bg = base00

    # Background color of disabled items in the context menu.
    c.colors.contextmenu.disabled.bg = base01

    # Foreground color of disabled items in the context menu.
    c.colors.contextmenu.disabled.fg = base04

    # Background color of the context menu. If set to null, the Qt default is used.
    c.colors.contextmenu.menu.bg = base00

    # Foreground color of the context menu. If set to null, the Qt default is used.
    c.colors.contextmenu.menu.fg =  base05

    # Background color of the context menu’s selected item. If set to null, the Qt default is used.
    c.colors.contextmenu.selected.bg = base0D

    #Foreground color of the context menu’s selected item. If set to null, the Qt default is used.
    c.colors.contextmenu.selected.fg = base00

    # Background color for the download bar.
    c.colors.downloads.bar.bg = base00

    # Color gradient start for download text.
    c.colors.downloads.start.fg = base00

    # Color gradient start for download backgrounds.
    c.colors.downloads.start.bg = base0D

    # Color gradient end for download text.
    c.colors.downloads.stop.fg = base00

    # Color gradient stop for download backgrounds.
    c.colors.downloads.stop.bg = base0C

    # Foreground color for downloads with errors.
    c.colors.downloads.error.fg = base08

    # Font color for hints.
    c.colors.hints.fg = base00

    # Background color for hints. Note that you can use a `rgba(...)` value
    # for transparency.
    c.colors.hints.bg = base0A

    # Font color for the matched part of hints.
    c.colors.hints.match.fg = base05

    # Text color for the keyhint widget.
    c.colors.keyhint.fg = base05

    # Highlight color for keys to complete the current keychain.
    c.colors.keyhint.suffix.fg = base05

    # Background color of the keyhint widget.
    c.colors.keyhint.bg = base00

    # Foreground color of an error message.
    c.colors.messages.error.fg = base00

    # Background color of an error message.
    c.colors.messages.error.bg = base08

    # Border color of an error message.
    c.colors.messages.error.border = base08

    # Foreground color of a warning message.
    c.colors.messages.warning.fg = base00

    # Background color of a warning message.
    c.colors.messages.warning.bg = base0E

    # Border color of a warning message.
    c.colors.messages.warning.border = base0E

    # Foreground color of an info message.
    c.colors.messages.info.fg = base05

    # Background color of an info message.
    c.colors.messages.info.bg = base00

    # Border color of an info message.
    c.colors.messages.info.border = base00

    # Foreground color for prompts.
    c.colors.prompts.fg = base05

    # Border used around UI elements in prompts.
    c.colors.prompts.border = base00

    # Background color for prompts.
    c.colors.prompts.bg = base00

    # Background color for the selected item in filename prompts.
    c.colors.prompts.selected.bg = base0A

    # Foreground color of the statusbar.
    c.colors.statusbar.normal.fg = base05

    # Background color of the statusbar.
    c.colors.statusbar.normal.bg = base00

    # Foreground color of the statusbar in insert mode.
    c.colors.statusbar.insert.fg = base0C

    # Background color of the statusbar in insert mode.
    c.colors.statusbar.insert.bg = base00

    # Foreground color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.fg = base0A

    # Background color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.bg = base00

    # Foreground color of the statusbar in private browsing mode.
    c.colors.statusbar.private.fg = base0E

    # Background color of the statusbar in private browsing mode.
    c.colors.statusbar.private.bg = base00

    # Foreground color of the statusbar in command mode.
    c.colors.statusbar.command.fg = base04

    # Background color of the statusbar in command mode.
    c.colors.statusbar.command.bg = base01

    # Foreground color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.fg = base0E

    # Background color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.bg = base01

    # Foreground color of the statusbar in caret mode.
    c.colors.statusbar.caret.fg = base0D

    # Background color of the statusbar in caret mode.
    c.colors.statusbar.caret.bg = base00

    # Foreground color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.fg = base0D

    # Background color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.bg = base00

    # Background color of the progress bar.
    c.colors.statusbar.progress.bg = base0D

    # Default foreground color of the URL in the statusbar.
    c.colors.statusbar.url.fg = base05

    # Foreground color of the URL in the statusbar on error.
    c.colors.statusbar.url.error.fg = base08

    # Foreground color of the URL in the statusbar for hovered links.
    c.colors.statusbar.url.hover.fg = base09

    # Foreground color of the URL in the statusbar on successful load
    # (http).
    c.colors.statusbar.url.success.http.fg = base0B

    # Foreground color of the URL in the statusbar on successful load
    # (https).
    c.colors.statusbar.url.success.https.fg = base0B

    # Foreground color of the URL in the statusbar when there's a warning.
    c.colors.statusbar.url.warn.fg = base0E

    # Background color of the tab bar.
    c.colors.tabs.bar.bg = base00

    # Color gradient start for the tab indicator.
    c.colors.tabs.indicator.start = base0D

    # Color gradient end for the tab indicator.
    c.colors.tabs.indicator.stop = base0C

    # Color for the tab indicator on errors.
    c.colors.tabs.indicator.error = base08

    # Foreground color of unselected odd tabs.
    c.colors.tabs.odd.fg = base05

    # Background color of unselected odd tabs.
    c.colors.tabs.odd.bg = base00

    # Foreground color of unselected even tabs.
    c.colors.tabs.even.fg = base05

    # Background color of unselected even tabs.
    c.colors.tabs.even.bg = base00

    # Background color of pinned unselected even tabs.
    c.colors.tabs.pinned.even.bg = base0B

    # Foreground color of pinned unselected even tabs.
    c.colors.tabs.pinned.even.fg = base00

    # Background color of pinned unselected odd tabs.
    c.colors.tabs.pinned.odd.bg = base0B

    # Foreground color of pinned unselected odd tabs.
    c.colors.tabs.pinned.odd.fg = base00

    # Background color of pinned selected even tabs.
    c.colors.tabs.pinned.selected.even.bg = base0D

    # Foreground color of pinned selected even tabs.
    c.colors.tabs.pinned.selected.even.fg = base00

    # Background color of pinned selected odd tabs.
    c.colors.tabs.pinned.selected.odd.bg = base0D

    # Foreground color of pinned selected odd tabs.
    c.colors.tabs.pinned.selected.odd.fg = base00

    # Foreground color of selected odd tabs.
    c.colors.tabs.selected.odd.fg = base00

    # Background color of selected odd tabs.
    c.colors.tabs.selected.odd.bg = base0D

    # Foreground color of selected even tabs.
    c.colors.tabs.selected.even.fg = base00

    # Background color of selected even tabs.
    c.colors.tabs.selected.even.bg = base0D

    # Background color for webpages if unset (or empty to use the theme's
    # color).
    # c.colors.webpage.bg = base00


def apply(c, scheme='dracula', options={}):
    """ Apply color scheme
    :param c: qutebrowser configuration object
    :param scheme: color scheme
    :param options: optional spacing options
    """

    if scheme not in SCHEMES:
        raise ValueError(f"scheme should be one of: " + ", ".join(SCHEMES.keys()))

    palette = SCHEMES[scheme]

    spacing = options.get('spacing', {
        'vertical': 3,
        'horizontal': 3
    })

    padding = options.get('padding', {
        'top': spacing['vertical'],
        'right': spacing['horizontal'],
        'bottom': spacing['vertical'],
        'left': spacing['horizontal']
    })

    # Background color of the completion widget category headers.
    c.colors.completion.category.bg = palette['background']

    # Bottom border color of the completion widget category headers.
    c.colors.completion.category.border.bottom = palette['border']

    # Top border color of the completion widget category headers.
    c.colors.completion.category.border.top = palette['border']

    # Foreground color of completion widget category headers.
    c.colors.completion.category.fg = palette['purple']

    # Background color of the completion widget for even rows.
    c.colors.completion.even.bg = palette['background']

    # Background color of the completion widget for odd rows.
    c.colors.completion.odd.bg = palette['background-alt']

    # Text color of the completion widget.
    c.colors.completion.fg = palette['foreground']

    # Background color of the selected completion item.
    c.colors.completion.item.selected.bg = palette['selection']

    # Bottom border color of the selected completion item.
    c.colors.completion.item.selected.border.bottom = palette['selection']

    # Top border color of the completion widget category headers.
    c.colors.completion.item.selected.border.top = palette['selection']

    # Foreground color of the selected completion item.
    c.colors.completion.item.selected.fg = palette['foreground']

    # Foreground color of the matched text in the completion.
    c.colors.completion.match.fg = palette['orange']

    # Color of the scrollbar in completion view
    c.colors.completion.scrollbar.bg = palette['background']

    # Color of the scrollbar handle in completion view.
    c.colors.completion.scrollbar.fg = palette['foreground']

    # Background color for the download bar.
    c.colors.downloads.bar.bg = palette['background']

    # Background color for downloads with errors.
    c.colors.downloads.error.bg = palette['background']

    # Foreground color for downloads with errors.
    c.colors.downloads.error.fg = palette['red']

    # Color gradient stop for download backgrounds.
    c.colors.downloads.stop.bg = palette['background']

    # Color gradient interpolation system for download backgrounds.
    # Type: ColorSystem
    # Valid values:
    # - rgb: Interpolate in the RGB color system.
    # - hsv: Interpolate in the HSV color system.
    # - hsl: Interpolate in the HSL color system.
    # - none: Don't show a gradient.
    c.colors.downloads.system.bg = 'none'

    # Background color for hints. Note that you can use a `rgba(...)` value
    # for transparency.
    c.colors.hints.bg = palette['background']

    # Font color for hints.
    c.colors.hints.fg = palette['foreground']

    # Hints
    c.hints.border = '0px solid ' + palette['background-alt']

    # Font color for the matched part of hints.
    c.colors.hints.match.fg = palette['foreground-alt']

    # Background color of the keyhint widget.
    c.colors.keyhint.bg = palette['background']

    # Text color for the keyhint widget.
    c.colors.keyhint.fg = palette['purple']

    # Highlight color for keys to complete the current keychain.
    c.colors.keyhint.suffix.fg = palette['selection']

    # Background color of an error message.
    c.colors.messages.error.bg = palette['background']

    # Border color of an error message.
    c.colors.messages.error.border = palette['background-alt']

    # Foreground color of an error message.
    c.colors.messages.error.fg = palette['red']

    # Background color of an info message.
    c.colors.messages.info.bg = palette['background']

    # Border color of an info message.
    c.colors.messages.info.border = palette['background-alt']

    # Foreground color an info message.
    c.colors.messages.info.fg = palette['comment']

    # Background color of a warning message.
    c.colors.messages.warning.bg = palette['background']

    # Border color of a warning message.
    c.colors.messages.warning.border = palette['background-alt']

    # Foreground color a warning message.
    c.colors.messages.warning.fg = palette['red']

    # Background color for prompts.
    c.colors.prompts.bg = palette['background']

    # ## Border used around UI elements in prompts.
    c.colors.prompts.border = '1px solid ' + palette['background-alt']

    # Foreground color for prompts.
    c.colors.prompts.fg = palette['cyan']

    # Background color for the selected item in filename prompts.
    c.colors.prompts.selected.bg = palette['selection']

    # Background color of the statusbar in caret mode.
    c.colors.statusbar.caret.bg = palette['background']

    # Foreground color of the statusbar in caret mode.
    c.colors.statusbar.caret.fg = palette['orange']

    # Background color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.bg = palette['background']

    # Foreground color of the statusbar in caret mode with a selection.
    c.colors.statusbar.caret.selection.fg = palette['orange']

    # Background color of the statusbar in command mode.
    c.colors.statusbar.command.bg = palette['background']

    # Foreground color of the statusbar in command mode.
    c.colors.statusbar.command.fg = palette['pink']

    # Background color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.bg = palette['background']

    # Foreground color of the statusbar in private browsing + command mode.
    c.colors.statusbar.command.private.fg = palette['foreground-alt']

    # Background color of the statusbar in insert mode.
    c.colors.statusbar.insert.bg = palette['background-attention']

    # Foreground color of the statusbar in insert mode.
    c.colors.statusbar.insert.fg = palette['foreground-attention']

    # Background color of the statusbar.
    c.colors.statusbar.normal.bg = palette['background']

    # Foreground color of the statusbar.
    c.colors.statusbar.normal.fg = palette['foreground']

    # Background color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.bg = palette['background']

    # Foreground color of the statusbar in passthrough mode.
    c.colors.statusbar.passthrough.fg = palette['orange']

    # Background color of the statusbar in private browsing mode.
    c.colors.statusbar.private.bg = palette['background-alt']

    # Foreground color of the statusbar in private browsing mode.
    c.colors.statusbar.private.fg = palette['foreground-alt']

    # Background color of the progress bar.
    c.colors.statusbar.progress.bg = palette['background']

    # Foreground color of the URL in the statusbar on error.
    c.colors.statusbar.url.error.fg = palette['red']

    # Default foreground color of the URL in the statusbar.
    c.colors.statusbar.url.fg = palette['foreground']

    # Foreground color of the URL in the statusbar for hovered links.
    c.colors.statusbar.url.hover.fg = palette['cyan']

    # Foreground color of the URL in the statusbar on successful load
    c.colors.statusbar.url.success.http.fg = palette['foreground']

    # Foreground color of the URL in the statusbar on successful load
    c.colors.statusbar.url.success.https.fg = palette['green']

    # Foreground color of the URL in the statusbar when there's a warning.
    c.colors.statusbar.url.warn.fg = palette['yellow']

    # Status bar padding
    c.statusbar.padding = padding

    # Background color of the tab bar.
    ## Type: QtColor
    c.colors.tabs.bar.bg = palette['background']

    # Background color of unselected even tabs.
    ## Type: QtColor
    c.colors.tabs.even.bg = palette['background']

    # Foreground color of unselected even tabs.
    ## Type: QtColor
    c.colors.tabs.even.fg = palette['foreground']

    # Color for the tab indicator on errors.
    ## Type: QtColor
    c.colors.tabs.indicator.error = palette['red']

    # Color gradient start for the tab indicator.
    ## Type: QtColor
    c.colors.tabs.indicator.start = palette['orange']

    # Color gradient end for the tab indicator.
    ## Type: QtColor
    c.colors.tabs.indicator.stop = palette['green']

    # Color gradient interpolation system for the tab indicator.
    ## Type: ColorSystem
    # Valid values:
    # - rgb: Interpolate in the RGB color system.
    # - hsv: Interpolate in the HSV color system.
    # - hsl: Interpolate in the HSL color system.
    # - none: Don't show a gradient.
    c.colors.tabs.indicator.system = 'none'

    # Background color of unselected odd tabs.
    ## Type: QtColor
    c.colors.tabs.odd.bg = palette['background']

    # Foreground color of unselected odd tabs.
    ## Type: QtColor
    c.colors.tabs.odd.fg = palette['foreground']

    # ## Background color of selected even tabs.
    # ## Type: QtColor
    c.colors.tabs.selected.even.bg = palette['selection']

    # ## Foreground color of selected even tabs.
    # ## Type: QtColor
    c.colors.tabs.selected.even.fg = palette['foreground']

    # ## Background color of selected odd tabs.
    # ## Type: QtColor
    c.colors.tabs.selected.odd.bg = palette['selection']

    # ## Foreground color of selected odd tabs.
    # ## Type: QtColor
    c.colors.tabs.selected.odd.fg = palette['foreground']

    # Tab padding
    c.tabs.padding = padding
    c.tabs.indicator.width = 1
    c.tabs.favicons.scale = 1
