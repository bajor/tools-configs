--[[
  Neovim Configuration

  Structure:
    lua/
      core/
        options.lua    - Basic vim options
        keymaps.lua    - Key mappings
        autocmds.lua   - Autocommands
      config/
        python_format.lua - Python formatting helper
      plugins/
        init.lua       - Plugin list (vim-plug)
        lsp/
          init.lua     - LSP setup & diagnostics
          servers.lua  - LSP server configs
          colors.lua   - Diagnostic colors
        completion.lua - nvim-cmp setup
        treesitter.lua - Treesitter config
        telescope.lua  - Telescope config
        ui.lua         - Theme, statusline, icons
        tools.lua      - Terminal, git, comments
]]

-- Load core settings
require('core.options')
require('core.keymaps')
require('core.autocmds')

-- Load plugins (vim-plug + configs)
require('plugins')
