# Architecture Diff

## Summary
Change the Neovim floating terminal shortcut from `<leader>j` to `<leader>f` and update the top README shortcut note.

## Diagram(s)

```mermaid
flowchart TD
    A[User presses <leader>f] --> B[Toggleterm open_mapping]
    B --> C[Floating terminal]
    D[nvim/README.md top note] --> A
```

## Changes

### Modified
- `nvim/lua/plugins/tools.lua`: Sets the shared Toggleterm floating terminal mapping value to `<leader>f`.
- `nvim/README.md`: Documents the floating terminal shortcut at the top of the README.
