--[[
  Neovim Configuration

  Structure:
    lua/
      core/
        options.lua    - Basic vim options
        keymaps.lua    - Key mappings
        autocmds.lua   - Autocommands
      config/
        (project helpers)
      plugins/
        init.lua       - Plugin list (vim-plug)
        lsp/
          init.lua     - LSP setup & diagnostics
          servers.lua  - LSP server configs
        completion.lua - nvim-cmp setup
        treesitter.lua - Treesitter config
        telescope.lua  - Telescope config
        ui.lua         - Theme, statusline, icons
        tools.lua      - Terminal, git, comments
]]

-- Load core settings
require('core.options')
require('core.clipboard')
require('core.keymaps')
require('core.autocmds')

-- Load plugins (vim-plug + configs)
require('plugins')
