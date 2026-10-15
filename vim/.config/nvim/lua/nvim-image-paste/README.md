# nvim-image-paste

Paste clipboard images as temporary file paths. Implemented as a standalone Lua
module so it can later be extracted into a plugin. Requires Neovim 0.10+;
there is no dependency on Node or a Neovim plugin manager.

## Usage

The local config calls `require("nvim-image-paste").setup()` in `lua/user/keymap.lua`.

| Mapping / command | Behavior |
| --- | --- |
| `Ctrl-V` (insert) | Paste clipboard image/file path or text at the cursor |
| `:ImagePaste` | Paste clipboard image/file path or text after the cursor |

Ordinary `p`/`P`, normal-mode `Ctrl-V` (visual block), terminal-mode input, and
terminal bracketed paste are untouched. Insert-mode `Ctrl-V` replaces Vim's
literal-character entry shortcut; use `Ctrl-Q` for literal entry if the terminal
passes it through, or disable this mapping and choose your own. No leader mappings
are installed.

To configure without installing mappings:

```lua
require("nvim-image-paste").setup({ mappings = false, timeout = 5000 })
vim.keymap.set({ "n", "x", "i" }, "<M-v>", function()
    require("nvim-image-paste").paste()
end)
```

`paste({ before = true })` uses `P` rather than `p` outside insert mode.
`read()` returns clipboard file/image path text (or `nil` for text fallback),
plus an error string if reading failed. It never changes the buffer or registers.
Commands are synchronous to keep insertion in the original buffer and selection;
clipboard reads are bounded by a one-second type-list timeout and a configurable
five-second data-read timeout. Backend errors warn and fall back to text.

## What gets pasted

- **macOS:** built-in `osascript` uses AppKit through JXA. Copied Finder files
  insert their existing paths, one per line. Otherwise PNG clipboard data is saved;
  TIFF (including screenshots) is converted to PNG. File URLs take priority over
  image data, so Finder thumbnails do not become spurious image attachments.
- **Linux:** `wl-paste` (from `wl-clipboard`) on Wayland; `xclip` on X11.
  Preferred image formats are PNG, JPEG, WebP, then GIF. If Wayland fails, X11 may
  be tried; an empty/non-image Wayland clipboard never falls through to stale X11
  pixels. Unsupported formats are not converted.
- **Plain text:** uses Neovim's existing `+` clipboard provider, retaining normal
  linewise/characterwise/blockwise put behavior. In insert mode it inserts text
  at the cursor.
- **Image URL copied as text:** stays a URL. There is no network download.
  Use the browser's **Copy Image** action, not **Copy Image Address**, to paste a
  temporary image path.

Image files live at `$TMPDIR/nvim-image-paste-XXXXXX/clipboard.<extension>` (the
platform's temp directory, not necessarily literal `/tmp`). Directories are 0700
and files are 0600. They intentionally survive Neovim exit, so paths remain usable
when Neovim was an external editor for an agent. The OS may eventually purge them;
move images into your project if the reference needs to be permanent. This module
does not automatically delete successfully saved images, even when the paste is
undone. No images or runtime state are stored in the dotfiles repository.

Windows/WSL-specific clipboard backends, remote clipboard image transport, Linux
file-manager URI lists, image previews, Markdown rendering, and URL downloads are
outside this initial version. Over SSH, clipboard access is to the host running
Neovim; OSC 52 does not transport image bytes for this module.
