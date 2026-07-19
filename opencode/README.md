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
