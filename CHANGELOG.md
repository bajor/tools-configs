# Changelog

## Unreleased

### Changed

- Remove Copilot, which needs a subscription this setup does not have: the
  Copilot language server, nvim-lspconfig (used only for it), the native
  inline completion hook, the Ctrl+y accept map, and Sidekick next edits.
  The agent pane and its maps stay.

- Add a real-config keymap regression check with optional JSON export.
  Give the insert completion keys descriptions: Tab, Shift+Tab, Enter and
  the arrow keys behave as before, and Ctrl+n and Ctrl+p now open the cmp
  menu. Disable Telescope's normal-mode Tab, which over mosh is the same
  byte as Ctrl+i.

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
