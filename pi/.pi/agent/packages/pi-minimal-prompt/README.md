# pi-minimal-prompt

A minimal prompt and status bar for the [Pi coding agent](https://pi.dev).

## Features

- Subtly filled, borderless prompt without a symbol prefix
- A single-space prefix for historical user messages
- Full-width status bar showing the working directory, context use, session cost, model, and thinking level
- Responsive layout with aligned autocomplete and viewport indicators
- Collapsed tool output by default

## Local installation

```sh
pi install /absolute/path/to/pi-minimal-prompt
```

## Published installation

Once published to npm:

```sh
pi install npm:pi-minimal-prompt
```

The prompt and status bar follow Pi's active theme. Set `"theme": "system"` in
`~/.pi/agent/settings.json` to follow the terminal palette, including live
light/dark appearance changes. No theme is bundled.
