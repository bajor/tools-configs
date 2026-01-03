-- Telescope configuration
local telescope = require('telescope')

telescope.setup({
  defaults = {
    file_ignore_patterns = {
      "node_modules",
      ".git",
      "target",
      ".bloop",
      ".metals",
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
})

telescope.load_extension('fzf')

-- Custom picker: search both file names and content
-- Filename matches appear first, then content matches
local function multi_grep()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local opts = {
    cwd = vim.fn.getcwd(),
  }

  pickers.new(opts, {
    prompt_title = 'Files + Content',
    finder = finders.new_async_job({
      command_generator = function(prompt)
        if not prompt or prompt == "" then
          return nil
        end
        -- Escape single quotes in prompt for shell safety
        local escaped = prompt:gsub("'", "'\\''")
        -- fd finds matching filenames (prefixed with F|)
        -- rg finds content matches (prefixed with C|)
        -- F sorts before C, so filename matches appear first
        local cmd = string.format(
          [[fd --type f --color never '%s' 2>/dev/null | sed 's/^/F|/' ; rg --no-heading --with-filename --line-number --column --color never --smart-case '%s' 2>/dev/null | sed 's/^/C|/']],
          escaped, escaped
        )
        return { 'sh', '-c', cmd }
      end,
      entry_maker = function(line)
        local prefix = line:sub(1, 2)
        local rest = line:sub(3)

        if prefix == "F|" then
          -- Filename match: just the path
          return {
            value = rest,
            display = rest .. "  [file]",
            ordinal = "A" .. rest, -- A sorts before B
            filename = rest,
            lnum = 1,
            col = 1,
          }
        elseif prefix == "C|" then
          -- Content match: path:line:col:text
          local filename, lnum, col, text = rest:match("^(.+):(%d+):(%d+):(.*)$")
          if filename then
            return {
              value = rest,
              display = rest,
              ordinal = "B" .. rest, -- B sorts after A
              filename = filename,
              lnum = tonumber(lnum),
              col = tonumber(col),
              text = text,
            }
          end
        end
        return nil
      end,
      cwd = opts.cwd,
    }),
    sorter = conf.generic_sorter(opts),
    previewer = conf.grep_previewer(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection.filename))
          if selection.lnum then
            vim.api.nvim_win_set_cursor(0, { selection.lnum, (selection.col or 1) - 1 })
          end
        end
      end)
      return true
    end,
  }):find()
end

return {
  multi_grep = multi_grep,
}
