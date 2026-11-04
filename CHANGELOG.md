# Changelog

## Unreleased

### Changed

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
