# Dependencies

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
