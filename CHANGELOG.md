# Changelog

## Unreleased

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
