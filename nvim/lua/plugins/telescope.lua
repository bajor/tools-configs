-- Telescope configuration
local telescope = require('telescope')

telescope.setup({
  defaults = {
    borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    mappings = {
      i = { ['<M-f>'] = false, ['<M-k>'] = false, ['<M-q>'] = false },
      n = { ['<M-f>'] = false, ['<M-k>'] = false, ['<M-q>'] = false, ['<Tab>'] = false },
    },
    file_ignore_patterns = {
      "node_modules",
      "%.venv/",
      "venv/",
      ".git",
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

-- Rex starts one Neovim per project root, which stays the global working
-- directory. Searching from it means a plugin's window-local :lcd cannot
-- narrow the search.
local function project_root()
  return vim.fn.getcwd(-1, -1)
end

local function find_files()
  require('telescope.builtin').find_files({ cwd = project_root() })
end

-- Custom picker: search both file names and content
-- Filename matches appear first, then content matches
local function multi_grep()
  local pickers = require('telescope.pickers')
  local finders = require('telescope.finders')
  local conf = require('telescope.config').values
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  local opts = {
    cwd = project_root(),
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
      -- fd and rg print paths relative to opts.cwd. filename stays relative
      -- because file_ignore_patterns (Lua patterns such as ".git") are
      -- matched against it. path is absolute, because :edit would resolve a
      -- relative name against the window's directory; Telescope prefers it.
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
            path = vim.fs.joinpath(opts.cwd, rest),
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
              path = vim.fs.joinpath(opts.cwd, filename),
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
        -- This picker's own selection: get_selected_entry() is a global that
        -- can still hold the previous picker's entry while results load.
        local selection = action_state.get_current_picker(prompt_bufnr):get_selection()
        actions.close(prompt_bufnr)
        if selection then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection.path))
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
  find_files = find_files,
  multi_grep = multi_grep,
}
