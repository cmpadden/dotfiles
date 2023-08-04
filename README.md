<div align="center">
    <img src="https://user-images.githubusercontent.com/5807118/173071635-c3f78d9a-0927-4b25-9e22-3978c00f9845.svg" alt="Logo project" height="80" />
    <br>
    <br>
    <p>
        <i>Personal System Configuration Files</i>
    </p>
</div>

---

## Applications

| -   | Category          | Name                                                | Tagline                                                                                                                                                                  |
| --- | ----------------- | --------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
|     | Editor            | [Vim](https://www.vim.org)                          | Vim is a highly configurable text editor built to make creating and changing any kind of text very efficient.                                                            |
| ⭐  | Editor            | [Neovim](https://neovim.io)                         | Hyperextensible Vim-based text editor                                                                                                                                    |
|     | Editor            | [VSCode](https://code.visualstudio.com)             | Code editing. Redefined.                                                                                                                                                 |
| ⭐  | Shell             | [Bash](https://www.gnu.org/software/bash/)          | Bash is the GNU Project's shell—the Bourne Again SHell. This is an sh-compatible shell that incorporates useful features from the Korn shell (ksh) and the C shell (csh) |
|     | Shell             | [Fish](https://fishshell.com)                       | Fish is a smart and user-friendly command line shell for Linux, macOS, and the rest of the family.                                                                       |
| ⭐  | Utility           | [Tmux](https://github.com/tmux/tmux)                | Tmux is a terminal multiplexer: it enables a number of terminals to be created, accessed, and controlled from a single screen.                                           |
| ⭐  | Terminal Emulator | [Kitty](https://sw.kovidgoyal.net/kitty/)           | The fast, feature-rich, GPU based terminal emulator                                                                                                                      |
|     | Terminal Emulator | [Alacritty](https://github.com/alacritty/alacritty) | A fast, cross-platform, OpenGL terminal emulator                                                                                                                         |
|     | Terminal Emulator | [urxvt](https://linux.die.net/man/1/urxvt)          | rxvt-unicode (ouR XVT, unicode) - (a VT102 emulator for the X window system)                                                                                             |
|     | Window Manager    | [i3wm](https://i3wm.org)                            | improved tiling wm                                                                                                                                                       |
| ⭐  | Utility           | [Hammerspoon](https://www.hammerspoon.org)          | This is a tool for powerful automation of OS X.                                                                                                                          |

_\* while I continue to explore various tools and applications -- the entries
marked with a star in the first column are my go-to favorites_

## Dependencies

- [GNU Stow](https://www.gnu.org/software/stow/)

## Neovim Dependencies

<details>
<summary>Language Servers, Formatters, and Linters</summary>

## Language Servers

https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

| Language                | Reference                                                                                       | Language Server | Installation Command                                 |
|-------------------------|-------------------------------------------------------------------------------------------------|-----------------|------------------------------------------------------|
| Bash                    | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#bashls        | bashls          | npm i -g bash-language-server                        |
| Javascript / Typescript | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint        | eslint          | npm i -g vscode-langservers-extracted                |
| HTML                    | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#html          | html            | npm i -g vscode-langservers-extracted                |
| JSON                    | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#jsonls        | jsonls          | npm i -g vscode-langservers-extracted                |
| Python                  | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#pyright       | pyright         | brew install pyright                                 |
| Rust                    | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer | rust_analyzer   | brew install rust-analyzer                           |
| Lua                     | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua   | sumneko_lua     | brew install lua-language-server                     |
| TailwindCSS             | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tailwindcss   | tailwindcss     | npm install -g @tailwindcss/language-server          |
| Typescript              | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tsserver      | tsserver        | npm install -g typescript typescript-language-server |
| Vue                     | https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#vuels         | vuels           | npm install -g vls                                   |

## Formatters / Linters

Dependencies used for code formatting, linting, and diagnostics by the `null-ls` plugin.

https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

| Reference                                                                                           | Installation Command                          |
|-----------------------------------------------------------------------------------------------------|-----------------------------------------------|
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#shellcheck             | brew install shellcheck                       |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#spell                  | -                                             |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#pylint                 | python3 -m pip install pylint                 |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#flake8                 | python3 -m pip install flake8                 |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#pydocstyle             | python3 -m pip install pydocstyle             |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#autopep8               | python3 -m pip install autopep8               |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#prettier               | npm install -g prettier                       |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#reorder_python_imports | python3 -m pip install reorder-python-imports |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#shfmt                  | -                                             |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#sqlfluff-1             | python3 -m pip install sqlfluff               |
| https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#stylua                 | brew install stylua                           |

## Debugging

### Neovim

| Error | Resolution |
| ----- | -----------|
| `invalid node type at position 2765 for language vim` | `rm /opt/homebrew/lib/nvim/parser/vim.so` |

</details>
