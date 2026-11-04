# Neovim on the VPS

## 1. Purpose

This config runs on Ubuntu through mosh and tmux from Rex on the Mac.
It supports Python editing with an AI assisting small changes that you review.
The key layout is being adapted for a 34-key Ferris Sweep.

Priorities: (1) mosh stability, (2) simplicity, (3) Python pairing,
(4) Sweep comfort, (5) a Rex-matched appearance.

## 2. Connection chain

```text
MacBook: Rex (terminal and multiplexer, built on libghostty)
   |
   | mosh 1.4+ on both ends
   v
Ubuntu VPS: tmux new-session -A -s main --> nvim
```

| Feature | Through mosh | Reason or alternative |
| --- | --- | --- |
| 24-bit color | Yes, 1.4+ | Both client and server must support RGB |
| OSC 52 copy | Yes, 1.4+ | tmux must allow clipboard writes |
| Mac paste | Yes | Rex sends Cmd+V as terminal input |
| OSC 52 read | No | No clipboard-query response; avoid timeout |
| Cmd mappings | No | Mac handles these before terminal input |
| Extended keys | No | Tab and Ctrl+i have the same encoding |
| Cursor shapes, undercurl | No | Screen re-rendering loses these details |
| Kitty graphics | No | Graphics escape sequences are not forwarded |
| Background queries | No | Cannot infer Rex's background reliably |
| FocusGained | Unreliable | Use activity-triggered disk checks instead |
| Rex OSC 7501 status | No | Agent status sequences are not forwarded |

Rex now documents a Linux server in testing, gated by Discord login:
<https://www.superlogical.com/rex/docs/linux/installation>.
This config keeps the mosh connection and does not require that server.

## 3. Requirements

Minimum supported versions for this rebuild: Neovim 0.12.0, mosh 1.4.0
on both ends, tmux 3.5a, ripgrep 14.1, fd 10.2, Node.js 22,
uv 0.8, tree-sitter CLI 0.26.1, and GCC 12 or Clang 14 with `make`.
Git and curl are needed to install plugins. Set a Nerd Font in Rex for icons.

The baseline on 2026-11-04 UTC was Neovim 0.11.6, tmux 3.5a, mosh
1.4.0 and Python 3.13.3, with no uv. Headless startup passed. The live
config was a copy with drift, including forced autosave via `write!`.
Provider health reported missing optional language hosts and clipboard.
All 33 live plugins reported installed. LSP health had no active clients
in an empty buffer and warned about non-Python filetypes.

## 4. Install and update

1. Back up `~/.config/nvim` and `~/.tmux.conf` before replacing them.
2. Link `~/.config/nvim` to this repository's `nvim-vps-linux` folder and
   `~/.tmux.conf` to `tmux/.tmux.conf`. Preserve unexplained local changes.
3. Install vim-plug's `plug.vim` in Neovim's `site/autoload` directory.
4. Run `:PlugInstall`, then `:VpsInstallTools` and `:VpsInstallParsers`.
   Mason and Treesitter install only when requested; restart after installation.
5. Run `:Copilot setup` for the current Copilot client. Native LSP Copilot
   and `:LspCopilotSignIn` arrive later in this rebuild.
6. Use `:PlugUpdate`, restart Neovim, and check `:PlugStatus` and
   `:checkhealth vim.lsp`. Run `:TSUpdate` when parser updates are needed.
7. Roll back a repository change with `git revert <commit>` on a branch,
   review it, and merge the PR. `:PlugSnapshot` can save plugin revisions
   before updates; use `:source <snapshot.vim>` to restore that snapshot.

Acceptance: `nvim --headless '+qa'` exits 0 with empty stderr.

## 5. How the pieces fit

Paths below are relative to this folder. Plugins install in `stdpath("data")/plugged`, separate from the old shared
`~/.vim/plugged` directory. Core `gc` and `gcc` handle comments; signature
help uses core LSP. Graphics and Raccoon review integrations are removed.
All plugins load at startup through
vim-plug. There is no lazy-loading framework.

| File | Owns |
| --- | --- |
| `init.lua` | Startup order |
| `scripts/edit-safety.lua` | Disk conflict and formatting regression |
| `scripts/python.lua` | uv, LSP imports and terminal command integration |
| `lua/core/options.lua` | Editor options and leader |
| `lua/core/keymaps.lua` | General, search, window and debug maps |
| `lua/core/autocmds.lua` | Yank highlight, autosave, save formatting |
| `lua/config/python.lua` | Project root and shared interpreter resolver |
| `lua/config/python_run.lua` | Run, pytest and rerun in Toggleterm |
| `lua/core/clipboard.lua` | OSC 52 copy, unnamed-register paste |
| `lua/plugins/formatting.lua` | Explicit-save Conform formatting |
| `lua/plugins/init.lua` | Authoritative plugin list and config loading |
| `lua/plugins/completion.lua` | Completion menu and snippets |
| `lua/plugins/treesitter.lua` | Parser installation and highlighting |
| `lua/plugins/telescope.lua` | Telescope and custom files+content picker |
| `lua/plugins/ui.lua` | Gruvbox, tree, statusline and Copilot Chat |
| `lua/plugins/tools.lua` | Terminal and Git signs |
| `lua/plugins/lsp/init.lua` | LSP attachment, Mason and diagnostics |
| `lua/plugins/lsp/servers.lua` | Servers and DAP |
| `lua/plugins/lsp/colors.lua` | Diagnostic highlight overrides |

Python is the only project language. Pyright, Ruff and debugpy remain;
Scala, C/C++, Go, Haskell, OCaml and Elixir servers and tools are removed.
Python parsers remain alongside Lua, Vim, help and Bash for maintaining this
config and using its terminal. These auxiliary filetypes have no LSP server.

The table describes the current config, including plugins scheduled for
removal. P1 to P5 refer to the priorities above; "remove" means there is
no reason to keep the plugin in the target config.

| Plugin | Why | Could core Neovim do this? |
| --- | --- | --- |
| morhetz/gruvbox | P5: current palette | Syntax yes, this palette no |
| nvim-web-devicons | P5: file icons | No icon registry |
| lualine.nvim | P5: visible INSERT block | Yes, custom statusline code |
| nvim-tree.lua | P4: file tree | Netrw, with different behavior |
| nvim-cmp | P3: completion menu | Yes, fewer menu controls |
| cmp-nvim-lsp | P3: LSP completion source | Yes, native completion |
| cmp-buffer | P3: words from buffers | Yes, Ctrl+n completion |
| cmp-path | P3: path completion | Yes, Ctrl+x Ctrl+f |
| LuaSnip | P3: existing snippets | Yes, native snippets |
| cmp_luasnip | P3: snippets in menu | Not with this menu |
| nvim-dap | P3: Python debugging | No DAP client |
| nvim-nio | P3: DAP UI dependency | Not this plugin API |
| nvim-dap-ui | P3: scopes and breakpoints | No debugger UI |
| plenary.nvim | P3: Telescope dependency | Not this plugin API |
| telescope.nvim | P3: files+content picker | No combined picker |
| telescope-fzf-native.nvim | P3: fast picker sorting | No fuzzy native sorter |
| conform.nvim | P3: ordered Ruff formatting on explicit save | Yes, custom formatter coordination |
| toggleterm.nvim | P3: reusable command output | Yes, more terminal glue |
| gitsigns.nvim | P3: review and stage hunks | No hunk staging UI |
| mason.nvim | P2: tool installation | No server package manager |
| nvim-treesitter | P3: parser installation | Highlighting yes, installer no |
| copilot.vim | P3: current inline AI | Replaced by native LSP client |
| CopilotChat.nvim | Remove: replaced by sidekick | No agent pane in core |

## 6. Python pairing loop

Create a project with `uv init`, add pytest with `uv add --dev pytest`,
and use `uv sync` after cloning an existing project. Open Neovim inside the
project. Pyright, DAP and run/test commands select the same interpreter:
`$VIRTUAL_ENV/bin/python`, project `.venv`, `venv`, `env`, then `python3`.
Roots are found from the current file, so launching Neovim above a project
also works. Run `:VpsInstallTools` after adding or updating tool requirements.

Pyright owns types, definitions, references and hover. Ruff owns lint,
import organization and formatting; Ruff hover and Pyright organize-imports
are disabled. The old diagnostic handler only filtered duplicates within
one server response, so it did not solve cross-server duplication and is removed.

Use Space r r to run the saved file, Space r t for `python -m pytest` on
that file, and Space r l to repeat the last command. Output stays in
Toggleterm terminal 1. Unsaved buffers are refused so commands cannot run
stale text. AI assistance is added in a later PR.

## 7. Keymaps

The authoritative mappings are in Lua. A generated table and printable Sweep
cheat sheet will replace this placeholder after the keyboard PR.

<!-- keymaps:start -->
<!-- keymaps:end -->

## 8. Look

The current theme is Gruvbox. A bright INSERT block supplies a mode indicator
because cursor shape changes do not survive mosh. Palette sync follows later.

## 9. Troubleshooting

Check `:messages`, `:PlugStatus`, `:checkhealth vim.lsp` and
`:checkhealth provider`. Missing optional language providers do not prevent
Lua LSP clients from running.

- Clipboard: copy with `"+yy`, paste on the Mac with Rex's Cmd+V. Within
  Neovim, `"+p` uses the unnamed register; it never queries the Mac.
- External edits: BufEnter, CursorHold, CursorHoldI and TermLeave run
  `checktime`, independent of focus notifications. Unmodified buffers reload.
- Conflicts: autosave compares the saved disk mtime, size and inode before
  writing. A mismatch blocks autosave and checks disk changes. Review both
  versions before choosing `:edit!` (discard local edits) or a manual save.
- Formatting: explicit `:w` runs Ruff import organization then formatting.
  Autosave on TextChanged/InsertLeave preserves your text without formatting.
  New unnamed files and read-only buffers are not autosaved.

Space+j mappings are fixed in the keyboard PR. If imports fail, check the
active virtual environment and the Python client settings in
`:checkhealth vim.lsp`; run `uv sync` and restart Neovim after creating a venv.

## 10. Maintenance

Run validation commands from the repository root. The Python integration
check creates a temporary uv project and installs pytest:
`nvim --headless "+luafile nvim-vps-linux/scripts/python.lua"`.

1. Add plugins only in `lua/plugins/init.lua`; add their reason and priority
   to the plugin table here. Prefer core features and existing plugins.
2. Keep each rule in one Lua file. Update this guide with behavior changes.
3. Add an entry under `Unreleased` in the repository's `CHANGELOG.md`.
4. Run `git diff --check`, headless startup and the edit safety regression:
   `nvim --headless "+luafile nvim-vps-linux/scripts/edit-safety.lua"`.
5. The keymap regression check and cheat-sheet generator arrive later in
   this series; until then inspect mappings with `:verbose map`.

Acceptance: documented behavior agrees with the config and startup succeeds.

## Personal notes

These historical notes are unrelated to the VPS editor configuration.

- setup local git in the directory where init.vim is so I can easily revert if I mess config
- copy to wsl :set ff=unix

## Gruvbox color scheme for Windows Terminal
```
Name of the color scheme
"name": "Gruvbox Dark"

Background and foreground colors
"background": "#282828", " Background color (dark)
"foreground": "#ebdbb2", " Foreground color (light text)

Normal colors
"black": "#282828",      " Black
"red": "#cc241d",        " Red
"green": "#98971a",      " Green
"yellow": "#d79921",     " Yellow
"blue": "#458588",       " Blue
"purple": "#b16286",     " Magenta (Purple)
"cyan": "#689d6a",       " Cyan
"white": "#a89984",      " White

Bright colors
"brightBlack": "#928374",    " Bright Black (Gray)
"brightRed": "#fb4934",      " Bright Red
"brightGreen": "#b8bb26",    " Bright Green
"brightYellow": "#fabd2f",   " Bright Yellow
"brightBlue": "#83a598",     " Bright Blue
"brightPurple": "#d3869b",   " Bright Magenta (Pink)
"brightCyan": "#8ec07c",     " Bright Cyan
"brightWhite": "#ebdbb2",    " Bright White
```


## Git - show staged changes
`git diff --cached`

## mvn
if JAVA_HOME not defined correctly
`sdk default java 17.0.8-tem`
`sdk env`

