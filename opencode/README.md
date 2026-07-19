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

Setting these variables does **not** make OpenCode's built-in prompt textbox behave like Neovim. Neovim mappings such as `jk` -> `Esc` only work after OpenCode launches the external editor.

In OpenCode, run:

```text
/editor
```

This opens the current prompt in Neovim. Write and edit the prompt there using your normal Neovim configuration and mappings, then save and quit with:

```vim
:wq
```

The edited text is returned to OpenCode's prompt composer, where it can be submitted normally.
