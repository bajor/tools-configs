# Claude Code settings

`settings.json` contains one portable preference: `"outputStyle": "Learning"`.
Learning may ask you to write small pieces of code and pause for your input,
so it is intended for interactive work rather than unattended implementation.

1. Open `~/.claude/settings.json`, creating it if missing. If it is a symlink,
   edit its target.
2. Merge the `outputStyle` key from this directory's `settings.json` into that
   file, preserving all other keys and formatting. Do not replace an existing
   settings file or symlink it to this checkout: Claude Code can write
   machine-specific settings into it.
3. Check project-level `.claude/settings.json` and `.claude/settings.local.json`
   for `outputStyle` overrides.
4. Run `/clear` or start a new Claude Code session to apply the change.

Setup is complete when the global setting is `"outputStyle": "Learning"`,
other settings are unchanged, and any project overrides are understood.
