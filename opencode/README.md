# OpenCode

To use Neovim as the external editor for writing OpenCode prompts, set these environment variables in your shell configuration:

```sh
export EDITOR="nvim"
export VISUAL="nvim"
```

For example, add them to `~/.zshrc` or `~/.bashrc`, then reload your shell configuration or start a new terminal session.

Verify the setup with:

```sh
echo "$EDITOR"
echo "$VISUAL"
```

Both should print `nvim`.

In OpenCode, use `/editor` (or the configured editor keybinding) to compose the current prompt in Neovim.
