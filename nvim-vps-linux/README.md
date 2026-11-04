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
5. Sign into the Claude and opencode CLIs separately; the agent pane uses
   their own authentication.
6. On a machine that ran the earlier Copilot version, run `:PlugClean` and
   `:MasonUninstall copilot-language-server` once to remove what is left.
7. Use `:PlugUpdate`, restart Neovim, and check `:PlugStatus` and
   `:checkhealth vim.lsp`. Run `:TSUpdate` when parser updates are needed.
8. Roll back a repository change with `git revert <commit>` on a branch,
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
| `scripts/completion.lua` | Batched typing and completion fallback regression |
| `scripts/keymaps.lua` | Validate public maps; export them as JSON on request |
| `scripts/python.lua` | uv, LSP imports and terminal command integration |
| `lua/core/options.lua` | Editor options and leader |
| `lua/core/keymaps.lua` | General, search, window and debug maps |
| `lua/core/autocmds.lua` | Yank highlight, autosave, save formatting |
| `lua/config/python.lua` | Project root and shared interpreter resolver |
| `lua/config/python_run.lua` | Run, pytest and rerun in Toggleterm |
| `lua/core/clipboard.lua` | OSC 52 copy, unnamed-register paste |
| `lua/plugins/formatting.lua` | Explicit-save Conform formatting |
| `lua/plugins/init.lua` | Authoritative plugin list and config loading |
| `lua/plugins/ai.lua` | Agent pane and AI maps |
| `lua/plugins/completion.lua` | Completion menu and snippets |
| `lua/plugins/treesitter.lua` | Parser installation and highlighting |
| `lua/plugins/telescope.lua` | Telescope and custom files+content picker |
| `lua/plugins/ui.lua` | Theme, tree, window names, indent guides and statusline |
| `lua/plugins/tools.lua` | Terminal and Git signs |
| `lua/plugins/lsp/init.lua` | LSP attachment, Mason and diagnostics |
| `lua/plugins/lsp/servers.lua` | Servers and DAP |

Python is the only project language. Pyright, Ruff and debugpy remain;
Scala, C/C++, Go, Haskell, OCaml and Elixir servers and tools are removed.
Python parsers remain alongside Lua, Vim, help and Bash for maintaining this
config and using its terminal. These auxiliary filetypes have no LSP server.

The table describes the current config, including plugins scheduled for
removal. P1 to P5 refer to the priorities above; "remove" means there is
no reason to keep the plugin in the target config.

| Plugin | Why | Could core Neovim do this? |
| --- | --- | --- |
| solarized-osaka.nvim | P5: palette synced to Rex | This palette no |
| flash.nvim | P4: letter jumps and syntax selection | Search yes, labels no |
| incline.nvim | P5: file name per window | Yes, custom floating windows |
| snacks.nvim (indent only) | P3/P5: indentation guides | No persistent guides |
| nvim-web-devicons | P5: file icons | No icon registry |
| lualine.nvim | P5: visible INSERT block | Yes, custom statusline code |
| nvim-tree.lua | P4: file tree | Netrw, with different behavior |
| nvim-cmp | P3: completion menu | Yes, fewer menu controls |
| cmp-nvim-lsp | P3: LSP completion source | Yes, native completion |
| cmp-buffer | P3: words from buffers | Yes, native Ctrl+n completion (Ctrl+n opens the cmp menu here) |
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
| sidekick.nvim | P3: scoped agent pane for Claude and opencode | Partly: a terminal split lacks the send maps |

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
stale text.

1. Write a Python function. Pyright offers completions as you type; Ctrl+n
   and Ctrl+p move through the menu and Enter confirms.
2. Select a small block, press Space a c for Claude or Space a o for opencode,
   then return to the selection and press Space a v to send it. Space a p
   offers four prompts: explain selection, fix diagnostics, write one test,
   review the current file's diff. Ask for one small change.
3. Leave terminal input with Ctrl+q. Review changes as Git hunks; the
   maps are Space g n/p/v/s/r for next/previous/preview/stage/reset.
4. Run the current test file with Space r t. Select a failure in the terminal's
   normal mode, then Space a v to send it to the agent.

Ask for changes small enough to review as hunks in under a minute. Sidekick
uses a right split with disk watching and no mux backend, so tmux is not
nested. Only Claude and opencode are listed. No CLI permission settings change.
There is no inline completion or next-edit suggestion here: both need a
Copilot plan, which this setup does not use. Completion comes from Pyright
through nvim-cmp.

## 7. Keymaps

Leader is Space. Feature maps use Space, a group letter, then an action
letter: f find, c code, r run, g Git, a AI, d debug. Single-letter Space
maps handle windows, terminal, tree, quickfix and search highlighting.
There are no leader maps in insert or terminal mode, Cmd/Alt/F-key maps,
symbol-led feature maps, or normal Tab/Ctrl+i maps. Ctrl+letters are used
for terminal and insert input only. Every custom map has a description.

The Sweep base is QWERTY with home-row Shift/Alt/Ctrl/GUI on
pinky/ring/middle/index fingers. Space is right inner thumb, Enter left
inner thumb; left outer thumb is Tab/symbol layer, right outer thumb is
Backspace/number-navigation layer. Esc is the Enter thumb on that layer.
The layout source is [bajor/zmk-config-ferris](https://github.com/bajor/zmk-config-ferris/blob/main/config/cradio.keymap).
Letters stay in their proposed groups because they are all on the base
layer. Flash s/S replaces long counted jumps. Redo stays on r by choice.
Nvim-tree uses o to open and q to close; Tab remains jump-forward in editors.

The generated table and printable Sweep diagrams follow in the final PR.

<!-- keymaps:start -->
<!-- keymaps:end -->

## 8. Look

Solarized Osaka uses `style = "vivid"` and transparent editor, sidebar and
float backgrounds. Rex supplies the background. On the Mac, import
craftzdog's [Solarized Dark - Vivid Ghostty theme](https://github.com/craftzdog/dotfiles/blob/master/dot_config/ghostty/themes/Solarized%20Dark%20-%20Vivid).
Its text colors use the same vivid transform; its surface colors stay dark.
The source file currently sets the terminal background to `#031219`.

There is one global lualine statusline and an Incline filename per editor
window. Snacks enables only indent guides with animations disabled. Rounded
float borders and a bright INSERT block remain visible through mosh.
Line numbers are absolute; use Flash after the keyboard PR for long jumps.
`cmdheight=0` uses experimental Neovim 0.12 ui2 under `pcall`.

If colors differ, check Rex's selected theme, `:set termguicolors?`, and
`tmux info` for client RGB/Tc after reconnecting. Set BlexMono Nerd Font or
another Nerd Font in Rex if icons appear as boxes. Glyphs render on the Mac.
A shell truecolor test is `printf '\033[38;2;50;185;170mRGB test\033[0m\n'`.
The VPS can verify settings, but cannot verify Rex's actual appearance.

## 9. Troubleshooting

- Agent pane: run `:checkhealth sidekick` to check that `claude` and
  `opencode` are installed. Ignore its "Copilot LSP" error: Copilot is not
  used here. In a Python buffer, `:checkhealth vim.lsp` should list pyright
  and ruff.
- Pyright uses the wrong interpreter after `uv sync` created or changed a
  venv in a running session: run `:lsp restart`. The interpreter is read when
  the server starts.

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

If imports fail, check the
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
5. Run the keyboard regression with
   `nvim --headless "+luafile nvim-vps-linux/scripts/keymaps.lua"`.
   It exits nonzero for any of these public maps: a Space prefix in insert,
   terminal, select, command-line or language-argument mode; Cmd, Alt or
   F-keys, alone or with another modifier; a global or leader map without a
   description; a normal Tab or Ctrl+i map. It checks the global maps and the
   buffer-local maps of the file tree, a terminal and a Telescope prompt.
   Buffers of other plugins (the Sidekick pane, DAP UI, Git previews) are not
   opened, so their maps are not checked. Native unchanged defaults and
   internal Plug targets are excluded; core gc/gcc are included. Set
   `VPS_KEYMAP_JSON=/path/keymaps.json` to also write the global maps and the
   colorscheme's red, green, yellow and blue ANSI colors as JSON with sorted
   keys. Nothing is written when a check fails.
   Also run `nvim --headless "+luafile nvim-vps-linux/scripts/completion.lua"`
   to verify that batched Enter and Tab input stays in order when the menu is
   closed and that Enter still expands abbreviations.
6. The printable generator and README key table follow in the final PR.

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

