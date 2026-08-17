# pi-minimal-prompt

A minimal prompt and status bar for the [Pi coding agent](https://pi.dev).

## Features

- Whimsy FIGlet startup banner while retaining Pi's loaded-resource list
- Subtly filled, borderless prompt with a bold lambda prefix
- Full-width status bar showing the working directory, context use, session cost, model, and thinking level
- Context-aware status colors inherited from the active Pi theme
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

The package works with any Pi theme and does not bundle one.
