## Automatic usage-limit recovery (OpenCode v2)

This setup reuses [azumag's MIT-licensed rate-limit plugin](https://github.com/azumag/opencode-rate-limit-fallback)
at version `2.1.1`, rather than maintaining a second implementation.
[`opencode.jsonc`](opencode.jsonc) loads it; [`rate-limit-fallback.json`](rate-limit-fallback.json)
selects same-model `wait` mode. Consecutive failures wait 1, 2, 4, 8, 16, 32,
then 60 minutes, without an attempt cutoff. Real user prompts reset the sequence.

1. Install Python 3 and OpenCode v2. Run from the repository root:
   ```sh
   python3 setup-auto-resume.py --target opencode
   ```
   The installer merges the plugin into `~/.config/opencode/opencode.json(c)` and
   its policy into `rate-limit-fallback.json`, respecting `XDG_CONFIG_HOME`.
   Existing changed files get timestamped backups; models, credentials, permissions,
   and unrelated settings are preserved. Comments/trailing commas or plugin objects
   require a manual merge instead, and the installer stops without modifying them.
2. For a manual merge, add `"@azumag/opencode-rate-limit-fallback@2.1.1"` to the
   global config's `plugins` array and merge these policy fields into the global
   `rate-limit-fallback.json`:
   ```json
   { "enabled": true, "fallbackMode": "wait", "cooldownMs": 60000 }
   ```
3. OpenCode loads config changes automatically; `/reload` forces a reload.
   Keep its service and session running. The plugin retries rate/usage limits
   on the same model, including after OpenCode exhausts its native retry budget.
   Interrupted turns are not automatically resumed. No paid overflow is enabled.
4. To uninstall, remove the plugin entry from your global config and run `/reload`.

Project/worktree policy files and `~/.opencode/rate-limit-fallback.json` take
precedence over `~/.config/opencode/rate-limit-fallback.json`. Check those locations
if behavior differs. Timers are not durable across plugin/service restarts. The
upstream matcher is broad: unlike the Pi extension, it also retries generic quota
messages, so permanent quota exhaustion requires manually interrupting the turn.
Automatic recovery can resume tool use under the session's existing permissions.

Acceptance: repeated temporary limits wait with increasing delays and resume the
same model without manual `continue` prompts; an interrupted turn stays stopped.

## CLI keybindings

[`cli.json`](cli.json) is a template for the global OpenCode CLI settings file. Merge its `keybinds` object into `~/.config/opencode/cli.json`, or `$XDG_CONFIG_HOME/opencode/cli.json` when `XDG_CONFIG_HOME` is set. It binds `Tab` to cycle to the next agent.

`Tab` is also OpenCode's default shortcut for accepting prompt autocomplete. This overlap is intentional for agent cycling; use `Return` to accept an autocomplete candidate.

## External editor

To use Neovim as the external editor for writing OpenCode prompts, set these environment variables in your shell configuration:

```sh
export EDITOR="nvim"
export VISUAL="nvim"
```

In OpenCode, run:

```text
/editor
```

## Output styles plugin

Install the plugin with `opencode plugin @capybearista/opencode-output-styles`, then select a style using `/output-style <name>`. I recommend the `explanatory` style for clearer technical explanations.

## LSP configuration

OpenCode does not enable LSP servers unless `lsp` is configured in `opencode.json`.

To enable all built-in LSP integrations:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": true
}
```

Use an object when you need explicit server commands, custom file extensions, or an LSP that is not built into OpenCode. For example:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "lsp": {
    "pyright": {
      "command": ["pyright-langserver", "--stdio"],
      "extensions": [".py", ".pyi"]
    },
    "metals": {
      "command": ["metals"],
      "extensions": [".scala", ".sc", ".sbt"]
    },
    "gopls": {
      "command": ["gopls"],
      "extensions": [".go"]
    },
    "lua-ls": {
      "command": ["lua-language-server"],
      "extensions": [".lua"]
    }
  }
}
```

The configured commands must be installed and available on `PATH`. Python, Go, and Lua have built-in OpenCode LSP integrations; the explicit entries above show how to control their extensions. Scala requires a custom server entry such as [Metals](https://scalameta.org/metals/).

Enabling LSP servers is separate from enabling OpenCode's experimental `lsp` agent tool. To expose operations such as go-to-definition, references, and hover to the agent, start OpenCode with:

```sh
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
```

See the [OpenCode LSP documentation](https://opencode.ai/docs/lsp/) for the current list of built-in servers and configuration options.
