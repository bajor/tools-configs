  ├── init.lua                    # Entry point
  ├── init.vim.bak                # Backup of old config
  └── lua/
      ├── core/
      │   ├── options.lua         # Basic vim settings
      │   ├── keymaps.lua         # Key mappings
      │   └── autocmds.lua        # Autocommands (format on save, etc.)
      ├── config/
      │   └── python_format.lua   # Python formatting helper (existing)
      └── plugins/
          ├── init.lua            # Plugin list (vim-plug)
          ├── lsp/
          │   ├── init.lua        # LSP setup & diagnostics
          │   ├── servers.lua     # All LSP server configs
          │   └── colors.lua      # Diagnostic colors
          ├── completion.lua      # nvim-cmp setup
          ├── treesitter.lua      # Treesitter config
          ├── telescope.lua       # Telescope config
          ├── ui.lua              # Theme, lualine, devicons, copilot chat
          └── tools.lua           # Toggleterm, gitsigns, comment
