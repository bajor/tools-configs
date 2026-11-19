# Changelog

## Unreleased

### Changed

- Add make_wallpaper.py and the root iPad wallpaper, a black 2048 x 2732
  sheet of 8 Rex and 8 Neovim shortcuts. Each row draws the Ferris Sweep with
  the keys lit, naming the home-row letter to hold rather than a modifier the
  keyboard has no key for. Its --check fails when a drawn Rex shortcut is not
  bound in rex/init.lua.
- Move file switching from Neovim to Rex: edit, buffers, buffer_cycle and
  search actions on Alt+p, Alt+b, Alt+n, Alt+Shift+n and Alt+f. Rex starts one
  Neovim per project with --listen and drives it over that socket, so nvim/
  needs no configuration. check_editor.py covers them on a throwaway server.
- Draw the Alt keys on poster page 4 and resolve the DejaVu fonts from the
  macOS font directory as well as the Debian one, so the poster rebuilds on
  both. Rebuilding on macOS shifts 11 bytes of the embedded font subset
  without changing a drawn page.
- Add make_poster.py, the generator of the root 4 x A4 Ferris Sweep poster,
  and regenerate the poster for Alt+h/j/k/l, the resize mode, agent and
  scratch keys. Its --check fails when the poster misses a shortcut.
- Remove ToggleTerm: Space+t toggles the Rex scratch action's floating shell,
  and Python run/test commands require a Rex terminal instead of falling
  back to an in-editor terminal.
- Move pane layout into Rex actions (agent, run, scratch) in rex/init.lua,
  bound to Ctrl+A c/o/i/e and listed in the Rex palette. :RexAgent and
  :RexRun call them through rex do; remove :RexSplitRight, :RexSplitBelow,
  :RexZoom and :RexFocus, which duplicated Rex keys.
- Move pane navigation into Rex: Alt+h/j/k/l focuses Rex panes with no
  prefix and hands the key to Neovim when it owns the pane, replacing
  Space+h/j/k/l and terminal-mode Ctrl+h/j/k/l. Ctrl+A h/j/k/l stays as a
  fallback. Replace Ctrl+A Shift+h/j/k/l with a Ctrl+A r resize mode.

### Changed

- Replace the remote terminal multiplexer and mosh configuration with
  native Rex Mac/Linux remote sessions; remove the old multiplexer directory.
- Add Rex Lua key sequences and test event automation, smart Neovim-to-Rex
  navigation, Rex agent/command panes and Python test output panes.
- Keep independent Neovim windows, Ferris Sweep bindings and the
  non-Rex ToggleTerm fallback; document SSH service lifetime and migration.

### Changed

- Merge the maintained `nvim-vps-linux/` into the canonical `nvim/`
  directory, replacing legacy config and removing the duplicate. Carry over
  Python/LSP settings, safe autosave, remote OSC 52, Ferris Sweep docs and tests.
- Make Neovim Space+h/j/k/l and terminal-mode Ctrl+h/j/k/l navigate tmux
  at editor boundaries, without stealing unprefixed shell controls.
- Add tmux prefix-based h/j/k/l pane focus, v/s working-directory splits,
  H/J/K/L pane resizing, last-pane and reload shortcuts.
- Rename VPS-specific Neovim installation commands and verification variables
  to NvimInstallTools, NvimInstallParsers, NVIM_CONFIG_BIN and NVIM_KEYMAP_JSON.

### Changed

- Move shared agent instructions out of this repository to
  [`bajor/skills/agents`](https://github.com/bajor/skills/tree/main/agents).
  Repoint any checkout-based links to a standalone `~/AGENTS.md` before updating.

- Include config-owned file-tree maps in the generated shortcut guide and
  remove stale deployment wording.

- Generate the Ferris Sweep cheat sheet (SVG and A4 PDF) and the README key
  table from the live Neovim maps with one script, `docs/keymap_sheet.py`,
  so shortcuts are not listed by hand anywhere. Shorten the conditional
  breakpoint description so it fits its key.

- Remove Copilot, which needs a subscription this setup does not have: the
  Copilot language server, nvim-lspconfig (used only for it), the native
  inline completion hook, the Ctrl+y accept map, and Sidekick next edits.
  The agent pane and its maps stay.
- Use native LSP menus instead of cmp and its snippet adapters,
  avoiding queued-input loss during confirmation and reducing dependencies.

- Add a real-config keymap regression check with optional JSON export.
  Give the insert completion keys descriptions. Ctrl+n/p request native
  completion, Enter confirms and Tab moves forward in its menu. Disable
  Telescope's normal-mode Tab, which over mosh is the same byte as Ctrl+i.

- Use Sweep letter groups, native comment keys, Flash jumps, described
  Git/code/window/debug maps and no insert/terminal Space prefix mappings.

- Replace the old Copilot clients with a scoped Claude/opencode pane
  without nested tmux.

- Match Neovim and tmux to Rex Solarized Dark - Vivid, with transparent
  surfaces, global status, per-window file names and indent guides.

- Share Python interpreter selection across Pyright, DAP and run/pytest
  commands; split Ruff/Pyright roles and install Mason tools explicitly.

- Reload external edits without focus events, block autosave on disk drift,
  format explicit writes with Conform/Ruff, and use OSC 52 copy/local paste.

- Remove VPS graphics, redundant snippets/comments/diagnostics/signature
  plugins and Raccoon integrations; isolate the VPS plugin directory.

- Keep Python as the only VPS project language; remove other servers,
  language plugins, parsers, debug targets and formatting rules.

- Replace the VPS Neovim scratch README with a current-config guide,
  plugin reasons, requirements and preserved personal notes.

- Configure VPS tmux RGB, 10 ms Esc handling, focus events, OSC 52 copy,
  and explicit Ctrl+a prefix; preserve live mouse scrolling.
- Remove mandatory PR visual explanations; generate them only on explicit request.
- Require frequent, descriptive logical commits and preservation of explanatory history.
- Document artifact-only Raccoon publication on PR branches and opt-in merge cleanup.
- Require text diagrams instead of Mermaid in Markdown that readers view on Entire, which does not render Mermaid.

## [0.1] - 2026-06-29

### Added

- Added `AGENTS.md` guidance for PR-only visual explanation SVGs.
- Added SVG flowcharts that explain the visual explanation lifecycle, generation flow, and merge cleanup flow.
- Added a workflow caller that removes merged visual explanation SVGs from `main`.
