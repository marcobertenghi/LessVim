# Neovim config

Minimal setup for Markdown notes, Python, and configuration reviews, using
Neovim 0.12's built-in plugin manager (`vim.pack`) — no vim-plug, no lazy.nvim, no Mason.
Prioritize fast startup and responsive editing: add plugins for concrete needs
and enable only the features used in this setup.

## Layout

```
init.lua                  entry point: options → plugins (vim.pack) → config modules
lua/
  options.lua             editor options
  keymaps.lua             general custom keymaps
  plugins/
    tree.lua              nvim-tree (file explorer)
    lualine.lua           statusline
    treesitter.lua        syntax highlighting, native folding + parser list
    markdown.lua          render-markdown + autolist
    completion.lua        Blink completion behaviour and completion keymaps
    lsp.lua               diagnostics, sort-imports + format-on-save, vim.lsp.enable
lsp/
  basedpyright.lua        basedpyright settings (types, hover, completion)
  ruff.lua                ruff settings (linting, formatting)
nvim-pack-lock.json       vim.pack lockfile (auto-generated, keep in git, don't edit)
.gitignore                local logs, sessions, swap files, and macOS metadata
LICENSE                   MIT license for this configuration
```

## Requirements

Install Neovim 0.12+, Git, ripgrep (`rg`), `curl`, `tar`, a C compiler, and
the tree-sitter CLI (0.26.1+). Add basedpyright and ruff for Python support.
All executables must be on your shell's `PATH`; this configuration preserves
that environment instead of overriding it with machine-specific directories.

On macOS with Homebrew:

```sh
brew install neovim git ripgrep tree-sitter basedpyright ruff
xcode-select --install      # C compiler, if Command Line Tools are not installed
```

On Linux, install the same tools with your preferred package manager. Check
the Neovim and tree-sitter versions; distribution packages may be older.
Use the tree-sitter CLI from its package manager or upstream release, not npm.
A Nerd Font is recommended for the file-tree and statusline icons.

### Kali Linux

The configuration targets macOS and 64-bit Kali Linux (x86_64 or ARM64).
macOS is tested; Kali compatibility has been reviewed against the pinned
plugins' requirements, but still needs a runtime check on your Kali machine.

| Requirement | Purpose |
|-------------|---------|
| Neovim 0.12+ | built-in `vim.pack`; 0.11 and older are incompatible |
| tree-sitter CLI 0.26.1+ | compile the configured parsers |
| Git, ripgrep, curl, tar, a C compiler | plugin installation, search, parser installation |
| basedpyright-langserver | Python completion, types, and navigation |
| Ruff 0.5.3+ | native Python language server, linting, and formatting |
| UTF-8 terminal with true colour | display, syntax colours, and Swiss keyboard aliases |

Install the base tools from Kali's repositories:

```sh
sudo apt update
sudo apt install neovim git ripgrep curl ca-certificates tar gzip unzip build-essential pipx python3-venv
```

Check the actual versions; Kali snapshots and rolling installations can differ:

```sh
apt-cache policy neovim tree-sitter-cli
nvim --version
```

If your Neovim is older than 0.12, use a suitable stable release from the
[official Neovim Linux downloads](https://github.com/neovim/neovim/blob/master/INSTALL.md#linux).
Choose the x86_64 or ARM64 archive for your Kali installation. Keep the entire
extracted directory, including its runtime, and put its `bin` directory before
`/usr/bin` on your shell's `PATH`. Confirm that `command -v nvim` and
`nvim --version` select the intended installation.

If `tree-sitter-cli` has an apt candidate at least 0.26.1, install it with
`sudo apt install tree-sitter-cli`. Otherwise, use an appropriate prebuilt CLI
from the [official tree-sitter releases](https://github.com/tree-sitter/tree-sitter/releases),
extract it, and install the `tree-sitter` executable in `~/.local/bin`.
Then check `tree-sitter --version`. A standalone release avoids installing a
Rust toolchain just to build this utility.

For Python tooling, use isolated user installations:

```sh
pipx install basedpyright
pipx install ruff
pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"  # make user-installed tools available now
basedpyright --version
ruff --version
command -v basedpyright-langserver
```

The [basedpyright PyPI distribution](https://docs.basedpyright.com/latest/installation/command-line-and-language-server/)
provides the language-server executable. The [Ruff installation documentation](https://docs.astral.sh/ruff/installation/)
also supports pipx. These tools are installed once per machine, not per project.

Clone only the configuration and its lockfile between macOS and Kali. Let each
machine install its own plugins and compile its own parsers; do not copy the
Neovim data directory or compiled parser libraries between operating systems.
Blink selects a platform-specific matcher and can fall back to Lua; its
[stable installation](https://cmp.saghen.dev/installation) does not require a
Rust toolchain when a compatible prebuilt binary is available.

After first launch and parser installation, run these checks in Neovim:

```vim
:checkhealth vim.pack nvim-treesitter blink.cmp telescope vim.lsp
:lua print(vim.inspect(vim.lsp.get_clients({ bufnr = 0 })))
```

For the second command, open a Python file first: basedpyright and ruff should
attach. Also test `<leader>fg`, syntax highlighting and folds in a configuration
file, and Python completion with `<C-n>` / `<C-y>`. Set your terminal font to a
Nerd Font if icons are missing; it is a display preference rather than a
requirement for navigation or editing.

Use the same committed `nvim-pack-lock.json` on both machines. For the closest
behaviour, use the same Neovim patch release and Python-tool versions too;
the plugin lockfile does not pin system executables. No Linux-specific plugin
or alternate Lua configuration is needed.

## Install on another machine

Clone this repository into Neovim's configuration directory. Replace
`YOUR-USERNAME` with the GitHub owner once the repository is published:

```sh
git clone https://github.com/YOUR-USERNAME/nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
```

If that destination already exists, move your current configuration to a
backup before cloning. On Windows, use Neovim's configuration directory
(normally `%LOCALAPPDATA%\nvim`) instead. The macOS setup is the tested platform.

## First launch

1. Open `nvim` — vim.pack asks to install the plugins; press `a` to accept all.
2. Treesitter parsers compile in the background on first run.
3. Open a `.py` file: you should get diagnostics, hover (`K`), completion as
   you type, and ruff import-sorting + formatting on save.

`nvim` and `nvim file.conf` start without the file tree. `nvim directory/`
opens that directory in the tree; `<leader>e` toggles it whenever needed.

## Plugin management

| Action              | Command                                        |
|---------------------|------------------------------------------------|
| Update all plugins  | `:lua vim.pack.update()` (then `:write` to confirm) |
| Remove a plugin     | delete its line in `init.lua`, then `:lua vim.pack.del({ 'name' })` |
| Health check        | `:checkhealth vim.pack`                        |

Commit `nvim-pack-lock.json` alongside the configuration to reproduce plugin
revisions. Plugins, compiled parsers, and editor state live in Neovim's data,
cache, and state directories; they do not belong in this repository.

## Keymaps

Leader is `<Space>`.
The `ö` / `ä` aliases are conveniences for a Swiss German keyboard. The native
`[` / `]` bindings remain available on every layout.

| Keys          | Action                          |
|---------------|---------------------------------|
| `<leader>e`   | toggle file tree                |
| `<leader>ff`  | find files (telescope)          |
| `<leader>fg`  | live grep (telescope)           |
| `<leader>fb`  | buffers (telescope)             |
| `<leader>fh`  | help tags (telescope)           |
| `<leader>qo`  | open quickfix review list       |
| `<leader>qc`  | close quickfix review list      |
| `<leader>qh`  | browse previous quickfix lists  |
| `äq` / `öq`   | next / previous quickfix entry  |
| `<C-b>` (ins) | insert fenced code block        |
| `gd`          | go to definition (LSP)          |
| `ö` / `ä`     | act as `[` / `]` (Swiss keyboard) |

Built-in LSP defaults (Neovim 0.11+): `K` hover, `grn` rename, `grr`
references, `gra` code action, `gri` implementation, `gO` document symbols,
`[d`/`]d` diagnostics, `]b`/`[b` next/prev buffer.

Code navigation between files: `gd` or `<C-]>` jumps to a symbol's
definition (any file), `<C-t>` / `<C-o>` jump back, `<C-i>` forward,
`<C-^>` toggles between the two most recent files.

## Configuration review workflow

Use quickfix as a queue of search matches to inspect:

1. Press `<leader>fg` and search for a directive, such as `ssl_protocols`.
2. Press `<C-q>` in Telescope to send the current results to quickfix and open it.
3. Press Enter on an entry to inspect it in its file. Use `äq` / `öq`
   (native `]q` / `[q`) to visit the next / previous match.
4. Close the list with `<leader>qc`; the results remain available. Reopen it
   with `<leader>qo`, or use `<leader>qh` to pick a previous result list.

Quickfix is a navigation list, not a persistent findings tracker. These
shortcuts use built-in Neovim features and the existing Telescope plugin.

In Markdown, Enter after ordinary text ending in `:` starts a bullet at the
same indentation as that text (e.g. `Notes:` followed by `- item`). Enter
after a list item ending in `:` starts a nested list. Tab / Shift-Tab control
list nesting, and fenced code blocks retain their normal newline behaviour.
Python's four-space indentation after a block-opening colon is independent.

Treesitter highlights TOML, INI, XML, HCL/Terraform, Dockerfiles, and Nginx
configuration, in addition to the existing Python, Bash, YAML, JSON, Lua,
JavaScript, HTML, and Markdown support. XML also installs its DTD parser dependency.
Parsers install on first launch;
reopen a file after installation completes if highlighting is not yet active.
For files with unusual names, set the filetype explicitly, e.g. `:setlocal filetype=nginx`.

Native Treesitter folding is enabled where the language supplies fold queries.
Files initially open expanded; fold choices are preserved when switching
between buffers in the same window. Use `za` to toggle the block under the
cursor, `zc` to close it, `zo` to open it, and `zR` to expand all blocks. Formats without fold
queries (currently Dockerfile among the added formats) still get highlighting.
Diff windows retain their native diff folds.

## Completion

Blink (`blink.cmp`, stable v1 releases) provides automatic completion from the
attached language server only. It refreshes as you type and backspace within
an identifier. For example, deleting the last character of `some_variabl`
still offers `some_variable` if that name is available from basedpyright.

| Keys (Insert mode) | Action |
|--------------------|--------|
| `<C-n>` / `<C-p>` | next / previous suggestion |
| `<Down>` / `<Up>` | next / previous suggestion |
| `<C-y>` | accept selected suggestion, or the first if none is selected |
| `<C-e>` | dismiss suggestions |
| `<C-Space>` | open suggestions; when open, toggle documentation |

Browsing suggestions does not insert text; acceptance is explicit. Tab keeps
its indentation behaviour, Enter keeps its newline behaviour, and Markdown's
list mappings and `<C-b>` fenced-code-block shortcut remain available.
If macOS intercepts `<C-Space>` for input-source switching, change that system
shortcut or use native manual LSP completion with `<C-x><C-o>`.

The setup uses Blink's Rust fuzzy matcher (a prebuilt binary downloaded on
first setup, with a Lua fallback if unavailable). No Rust toolchain is needed
on supported platforms. No extra completion sources, snippet collections, or
snippet-engine plugins are installed. Command-line and terminal completion
are disabled, and documentation opens on demand. Settings and completion
keys live in `lua/plugins/completion.lua`.

## Python tooling notes

- **basedpyright** does type checking, hover, go-to-definition, completion.
  Strictness is set in `lsp/basedpyright.lua` (`standard`).
- **ruff** lints, sorts imports, and formats; the last two run automatically
  on save (`lua/plugins/lsp.lua`). Configure rules per project in
  `pyproject.toml`.
- Import sorting is ruff's `source.organizeImports.ruff` code action, applied
  via a synchronous LSP request before the formatter runs. It only does
  something when the isort rules are selected for the project:

  ```toml
  # pyproject.toml
  [tool.ruff.lint]
  select = ["E", "F", "I"]   # "I" = isort, the rule behind I001
  ```

  Without `"I"`, ruff never reports "Import block is un-sorted or
  un-formatted" and the code action is a no-op.
- Not enabled on save: `source.fixAll.ruff`, which applies every safe autofix
  including *deleting* imports you haven't referenced yet. Run it manually
  with `gra` (code action) if you want it.

## License

This configuration is available under the [MIT License](LICENSE).
Plugins retain their respective licenses.
