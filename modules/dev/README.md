# Dev Tooling Inventory

This directory defines the development toolchain that Neovim expects to find in `PATH`.
The rule for this setup is simple: language servers, formatters, linters, debuggers, tree-sitter parsers, and CLI build tools should come from Nix, not from Neovim runtime installers.

## Neovim Runtime Provided By Nix

- `neovim`: editor binary.
- `tree-sitter`: generic tree-sitter CLI.
- `nvimTreesitterParsers`: prebuilt parsers mounted through `NVIM_TREESITTER_PARSERS`.
  Includes: `bash`, `c`, `cpp`, `css`, `go`, `html`, `java`, `javascript`, `json`, `kotlin`, `latex`, `lua`, `markdown`, `markdown_inline`, `nix`, `python`, `sql`, `swift`, `tsx`, `typescript`, `typst`, `vim`, `yaml`.
- `vimPlugins.one-small-step-for-vimkind`: Lua DAP server plugin exposed through `NVIM_OSV_PLUGIN`.

## Environment Variables Used By Neovim

- `NVIM_TREESITTER_PARSERS`: runtime path with tree-sitter parser `.so` files.
- `NVIM_OSV_PLUGIN`: path to the OSV plugin used for Lua debugging.
- `NVIM_CODELLDB`: path to the `codelldb` adapter from the VSCode LLDB extension.
- `NVIM_JAVA_DEBUG_BUNDLE`: path to Java debug JARs used by `nvim-jdtls`.
- `NVIM_JS_DEBUG`: path to the `js-debug` adapter binary.

## Language Tooling

### Shell

- Module: `languages/shell.nix`
- LSP: `bash-language-server`
- Formatter: `shfmt`
- Linter: `shellcheck`
- Debugger: none configured in Neovim
- Notes: used by `bashls` and `none-ls` for `sh`, `bash`, and `zsh` buffers.

### C And C++

- Module: `languages/cpp.nix`
- Toolchains: `gcc`, `clang`
- Build tools: `gnumake`, `cmake`
- LSP: `clangd` from `clang-tools`
- Formatter: `clang-format` from `clang-tools`
- Linter: `cppcheck`
- Debuggers: `gdb`, `lldb`, `codelldb` from `vscode-extensions.vadimcn.vscode-lldb`
- Notes: Neovim uses `clangd`, `cppcheck`, and `codelldb`; CLI debuggers remain available for terminal use.

### Go

- Module: `languages/go.nix`
- Compiler and SDK: `go`
- LSP: `gopls`
- Formatter support: `gofumpt`, `gotools`
- Linter: `golangci-lint`
- Debugger: `delve`
- Notes: Neovim formats through `gopls`, lints through `golangci-lint`, and debugs through `nvim-dap-go` + `dlv`.

### Java

- Module: `languages/java.nix`
- Runtime and compiler: `openjdk`
- LSP: `jdt-language-server`
- Formatter: `google-java-format`
- Build tools: `maven`, `gradle`
- Linters and static analysis: `checkstyle`, `pmd`
- Debugging and test adapters: `vscode-java-debug`, `vscode-java-test`
- Notes: Neovim uses `nvim-jdtls`, the Java debug bundle exported through `NVIM_JAVA_DEBUG_BUNDLE`, and `google-java-format` through `none-ls`.

### Kotlin

- Module: `languages/kotlin.nix`
- Runtime and compiler: `openjdk`, `kotlin`
- LSP: `kotlin-language-server`
- Build tools: `gradle`, `maven`
- Formatter: `ktlint`
- Linters and static analysis: `ktlint`, `detekt`
- Debugger: none configured in Neovim yet
- Notes: Neovim uses `kotlin-language-server` for LSP, `ktlint` through `none-ls` for formatting and diagnostics, and `detekt` through buffer-local commands.

### JavaScript, TypeScript, HTML, And CSS

- Module: `languages/javascript.nix`
- Runtime: `nodejs_22`
- Core toolchain: `typescript`, `tsx`, `esbuild`
- Package managers: `pnpm`, `yarn`
- LSP: `typescript-language-server`, `vscode-langservers-extracted`
- Formatters: `prettier`, `prettierd`
- Linters: `eslint`, `eslint_d`
- Debugger: `vscode-js-debug`
- Notes: Neovim uses `ts_ls`, `vscode-html-language-server`, `vscode-css-language-server`, `prettier`, `eslint`, and `js-debug` through `NVIM_JS_DEBUG`.

### Lua

- Module: `languages/lua.nix`
- Runtime: `lua5_4`
- LSP: `lua-language-server`
- Formatter: `stylua`
- Linter: `luacheck`
- Test runner: `busted`
- Debugger: `one-small-step-for-vimkind`
- Notes: Lua debug support is exposed to Neovim through `NVIM_OSV_PLUGIN`.

### Nix

- Module: `languages/nix.nix`
- LSP: `nil`, `nixd`
- Formatter: `nixfmt`
- Linters: `statix`, `deadnix`
- Debugger: none
- Notes: Neovim currently uses `nil` and `none-ls`; `nixd` is installed for CLI or future LSP switching.

### Python

- Module: `languages/python.nix`
- Runtime: `python3.withPackages(...)`
- Included Python packages: `numpy`, `matplotlib`, `pandas`, `scipy`, `debugpy`, `pytest`, `mypy`, `build`, `scikit-learn`
- Project tools: `uv`, `poetry`
- LSP: `pyright`
- Formatter: `black`
- Linters and type checking: `ruff`, `mypy`
- Debugger: `debugpy`
- Notes: Neovim uses `pyright`, `black`, `ruff`, and `debugpy`; `mypy` is exposed through custom commands.

### SQL

- Module: `languages/sql.nix`
- LSP: `sqls`
- Formatter and linter: `sqlfluff`
- Formatter helper: `pgformatter`
- Debugger: none
- Notes: Neovim uses `sqls` plus `sqlfluff` through `none-ls`.

### Swift

- Module: `languages/swift.nix`
- Toolchain: `swift`
- LSP: `sourcekit-lsp`
- Formatter: `swift-format`
- Linter: `swiftlint`
- Debugger: `lldb`, `lldb-dap`
- Notes: Neovim uses `sourcekit-lsp`, `swift-format`, and `swiftlint`; DAP is configured against `lldb-dap`.

### TeX, Markdown, And Typst

- Module: `languages/tex.nix`
- TeX LSP: `texlab`
- TeX toolchain: `texlive.combine` with `scheme-medium`, `latexmk`, `latexindent`, `collection-latex`, `collection-latexrecommended`, `collection-fontsrecommended`, `chktex`, `collection-langcyrillic`
- Typst toolchain: `typst`, `tinymist`, `typstyle`
- Markdown toolchain: `marksman`, `mdformat`, `pandoc`
- Debugger: none
- Notes: Neovim uses `texlab`, `latexmk`, `latexindent`, `chktex`, `tinymist`, `typstyle`, and `marksman`.

## What Neovim Still Downloads Itself

- Plugin repositories are still fetched by `lazy.nvim` into `~/.local/share/nvim/lazy`.
- This is plugin management, not language tooling.
- Language tooling downloads through Neovim were intentionally avoided here:
  `mason.nvim` is not used,
  `nvim-treesitter` parser auto-install is disabled,
  and Kotlin/Swift support added in this pass relies on Nix-provided binaries.
