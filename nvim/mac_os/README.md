# nvim

Personal Neovim config. Pure Lua, vim-plug.

## What's Different

- **Native LSP** — Uses `vim.lsp.config`/`vim.lsp.enable()`, not nvim-lspconfig
- **Auto-save** — Files save on TextChanged and InsertLeave
- **Python** — Organizes imports before formatting on save
- **Scala** — Metals with DAP debugging

## Languages

C/C++, Haskell, Go, Elixir, Python, OCaml, Scala

## Structure

```
init.lua                    # Entry point
lua/
  core/
    options.lua             # vim.opt settings
    keymaps.lua             # Key mappings
    autocmds.lua            # Format on save, auto-save
  plugins/
    init.lua                # vim-plug + plugin configs
    lsp/
      init.lua              # LSP setup, Mason
      servers.lua           # Server configs
    completion.lua          # nvim-cmp
    telescope.lua           # Fuzzy finder
    ui.lua                  # Theme, lualine, Copilot Chat
```

## Keys

| Key | Action |
|-----|--------|
| `<Space>` | Leader |
| `<Leader>ff` | Find files |
| `<Cmd-p>` | Live grep |
| `<Cmd-Shift-e>` | File tree |
| `gd` / `gi` / `gr` | Definition / Implementation / References |
| `<Leader>ca` | Code actions |
| `<F2>` | Rename |
| `jk` | Exit insert |
