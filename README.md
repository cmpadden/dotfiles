<div align="center">
    <img src="https://github.com/cmpadden/dotfiles/assets/5807118/8111f6b9-3460-4a27-a84b-cab7a0c090a6" alt="Logo project" height="160" />
</div>

## Dependencies

- [GNU Stow](https://www.gnu.org/software/stow/) is used to symbolically link configuration files to
the home directory.

## Tools

These are the applications and utilities that I choose to use at the moment, reference the
[Appendix](#appendix) to see utilities that were used in the days bygone.

| Name                                       | Tagline                                                                                                                                                                  | Category |
|--------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------|
| [Neovim](https://neovim.io)                | Hyperextensible Vim-based text editor                                                                                                                                    | Editor   |
| [Bash](https://www.gnu.org/software/bash/) | Bash is the GNU Project's shell—the Bourne Again SHell. This is an sh-compatible shell that incorporates useful features from the Korn shell (ksh) and the C shell (csh) | Shell    |
| [Kitty](https://sw.kovidgoyal.net/kitty/)  | The fast, feature-rich, GPU based terminal emulator                                                                                                                      | Terminal |
| [Tmux](https://github.com/tmux/tmux)       | Tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.                                           | Utility  |
| [Hammerspoon](https://www.hammerspoon.org) | This is a tool for powerful automation of OS X.                                                                                                                          | Utility  |

---

<details>
<summary>Legacy Utilities</summary>

| Name                                                | Tagline                                                                                                       | Category          |
|-----------------------------------------------------|---------------------------------------------------------------------------------------------------------------|-------------------|
| [Vim](https://www.vim.org)                          | Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient. | Editor            |
| [VSCode](https://code.visualstudio.com)             | Code editing. Redefined.                                                                                      | Editor            |
| [Fish](https://fishshell.com)                       | Fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family.            | Shell             |
| [Alacritty](https://github.com/alacritty/alacritty) | A fast, cross-platform, OpenGL terminal emulator                                                              | Terminal Emulator |
| [urxvt](https://linux.die.net/man/1/urxvt)          | rxvt-unicode (ouR XVT, unicode) - (a VT102 emulator for the X window system)                                  | Terminal Emulator |
| [i3wm](https://i3wm.org)                            | improved tiling wm                                                                                            | Window Manager    |

</details>


<details>
<summary>Troubleshooting</summary>

#### Neovim

| Error | Resolution |
| ----- | -----------|
| `invalid node type at position 2765 for language vim` | `rm /opt/homebrew/lib/nvim/parser/vim.so` |

</details>
