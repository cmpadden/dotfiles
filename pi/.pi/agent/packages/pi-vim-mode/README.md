# pi-vim-mode

Vim-style modal editing for Pi's input editor. The extension wraps the active editor, so it composes with custom prompt packages. Its normal-mode bindings are a key-sequence trie, with parser state only for counts and pending operators.

## Bindings

- `Esc`: enter normal mode; cancel a pending operator; otherwise retain Pi's normal Escape behavior
- `i`, `a`, `I`, `A`: enter insert mode (`a` advances one character first; `I`/`A` move to line start/end)
- `o`, `O`: open a line below/above and enter insert mode
- `h`, `j`, `k`, `l`: move by character
- `b`, `w`, `e`: move by word; `e` moves to the word end
- `W`, `E`: move by whitespace-delimited word; `E` moves to its end
- `0`, `$`: line start/end
- `x`: delete character
- `dd`, `d0`, `d$`, `db`, `dB`, `dw`, `dW`, `de`, `dE`: delete motions
- `D`: delete from cursor through line end
- Counts compose with motions and deletion, such as `2w`, `3dd`, and `d2w`

The status bar shows `INSERT`, `NORMAL`, or `NORMALd` while `d` awaits its motion.
