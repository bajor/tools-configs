# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal Neovim configuration using vim-plug for plugin management. The config is written entirely in Lua.

## Architecture

```
init.lua                    # Entry point - loads core/ then plugins/
lua/
  core/
    options.lua             # vim.opt settings, leader = space
    keymaps.lua             # Key mappings (Telescope, NvimTree, etc.)
    autocmds.lua            # Format-on-save, yank highlight
  config/
    python_format.lua       # Python-specific: organize imports then format
  plugins/
    init.lua                # vim-plug declarations, loads all plugin configs
    lsp/
      init.lua              # LSP setup, diagnostic dedup, Mason
      servers.lua           # Individual LSP server configs
      colors.lua            # Diagnostic highlight colors
    completion.lua          # nvim-cmp with LuaSnip
    treesitter.lua          # Treesitter parsers
    telescope.lua           # Fuzzy finder
    ui.lua                  # Gruvbox theme, lualine, devicons, Copilot Chat
    tools.lua               # toggleterm, gitsigns, Comment.nvim
```

## Key Design Patterns

**LSP Configuration**: Uses Neovim's native `vim.lsp.config` and `vim.lsp.enable()` pattern (not lspconfig plugin). Each server is configured in `lua/plugins/lsp/servers.lua` with capabilities from nvim-cmp.

**Metals (Scala)**: Special handling via nvim-metals plugin with FileType autocmd to initialize. Includes DAP debugging support.

**Format on Save**: Implemented via BufWritePre autocmds in `autocmds.lua`. Python has custom handling that runs `source.organizeImports` code action before formatting.

**Plugin Loading**: vim-plug handles installation; Lua configs are required after `plug#end()`.

## Supported Languages

LSP servers (auto-installed via Mason):
- C/C++: clangd
- Haskell: haskell-language-server
- Go: gopls (with gofumpt)
- Elixir: elixir-ls
- Python: pyright + ruff (linting/formatting)
- OCaml: ocamllsp
- Scala: Metals (via nvim-metals)

## Key Bindings

- `<Space>` is leader
- `<Leader>ff` - Find files (Telescope)
- `<Cmd-p>` - Live grep
- `<Cmd-Shift-e>` - Toggle NvimTree
- `<Cmd-Shift-i>` - Toggle Copilot Chat
- `gd/gi/gr` - LSP go to definition/implementation/references
- `<Leader>ca` - Code actions
- `<F2>` - Rename symbol
- `<Cmd-/>` - Toggle comment
- `jk` - Exit insert mode
