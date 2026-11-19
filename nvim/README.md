# Neovim for Rex on Mac and Linux VPS

This is the single Neovim configuration. It uses native Rex sessions,
terminals and panes, without nested multiplexers or mosh. The remote
connection is Rex for macOS -> SSH -> Rex Server on Linux -> Neovim.
The editor stays useful outside Rex, with an in-editor terminal fallback.

## Installation

1. Install Rex for macOS and the official Rex Server beta on your Linux VPS.
   Follow the linked rex/README.md instructions for SSH access and service
   persistence. Do not expose an anonymous server over the public internet.
2. Back up existing ~/.config/nvim, then link it to the repo nvim/ directory.
3. Install Neovim 0.12+, vim-plug, Node.js 22, ripgrep, fd, uv, compiler
   toolchain and Git. A Nerd Font in Rex gives correct symbols.
4. In Neovim, run :PlugInstall, :NvimInstallTools and :NvimInstallParsers.
   Restart the editor after installing plugins and parsers.
5. Authenticate agent CLIs separately if they are needed.

## Editor and Rex navigation

Alt+h/j/k/l moves left/down/up/right with no prefix. Rex owns the key
(rex/init.lua): in a shell, agent or test pane it focuses the next Rex
pane; in a pane running Neovim it hands the key to Neovim. In normal,
insert and terminal mode Neovim then switches editor windows first and,
when there is no adjacent editor window, runs rex focus in the same Rex
session. Insert and terminal mode return to normal mode first. Ctrl+A then
h/j/k/l always focuses Rex panes, from any program. Editor-to-Rex hand-off requires REX_BLOCK and the local
Rex CLI; it does not cross a plain SSH shell or focus another Rex server.

Space+v and Space+s create editor windows. Ctrl+A then v/s in Rex creates
independent terminal panes. Shell Ctrl+h/j/k/l keys remain untouched.

Rex actions own pane layout (rex/README.md); Neovim only calls them:
- :RexAgent opencode, :RexAgent claude or :RexAgent pi starts an agent
- :RexRun go test ./... runs a command and preserves its output
Use Rex keys for splits, zoom and focus. Errors from Rex, such as an
unknown agent name, appear as Neovim warnings.

CLI operations use argument arrays, not concatenated shell text. The
Python runner retains its existing shell command generation.
The existing Sidekick in-editor agent pane is still available separately.

## Python development

Pyright provides types, definitions and completion; Ruff handles lint and
formatting; debugpy provides DAP. One interpreter resolver is shared by
LSP, DAP and Python run/test actions. Space+rr runs the current saved
Python file, Space+rt runs pytest on it, and Space+rl repeats.
When inside a native Rex terminal, commands run in a new Rex pane below
with retained output. Outside Rex they use ToggleTerm as before.

External editor changes are checked on activity instead of relying only
on terminal focus events. Automatic saves refuse conflicting disk changes.
Explicit :w runs Ruff formatting via Conform; unsaved Python buffers
are not executed.

Clipboard: OSC 52 remains a conservative write-only provider. Try
"+yy to copy to the host clipboard; use Rex Cmd+V to paste Mac clipboard
text into the terminal. Clipboard reads from the remote host are not
assumed to work without verification of the installed Rex build.

## Verification (from repository root)

    nvim --headless '+qa'
    nvim --headless '+luafile nvim/scripts/rex.lua'
    nvim --headless '+luafile nvim/scripts/edit-safety.lua'
    nvim --headless '+luafile nvim/scripts/keymaps.lua'
    nvim --headless '+luafile nvim/scripts/completion.lua'
    nvim --headless '+luafile nvim/scripts/python.lua'
    python3 nvim/docs/keymap_sheet.py --check

The Python integration test needs uv, Mason-installed Pyright/Ruff and
pytest. The keyboard reference is generated from the unchanged Neovim
mappings; Ferris Sweep SVG/PDF remain under nvim/docs. Rex bindings live in
rex/init.lua and are documented in rex/README.md. Alt+h/j/k/l are the only
Alt maps Neovim may define; nvim/scripts/keymaps.lua rejects any other.

## Generated Neovim keyboard reference

<!-- keymaps:start -->
| Mode | Keys | Action |
| --- | --- | --- |
| i | `<C-N>` | Completion next |
| i | `<C-P>` | Completion previous |
| t | `<C-Q>` | Terminal normal mode |
| i | `<CR>` | Confirm completion or newline |
| i,n,t | `<M-h>` | Window left |
| i,n,t | `<M-j>` | Window down |
| i,n,t | `<M-k>` | Window up |
| i,n,t | `<M-l>` | Window right |
| n,x | `<Space>aa` | Toggle agent pane |
| n,x | `<Space>ac` | Open Claude |
| n,x | `<Space>ad` | Detach agent |
| n,x | `<Space>af` | Send file |
| n,x | `<Space>ao` | Open opencode |
| n,x | `<Space>ap` | Select scoped prompt |
| n,x | `<Space>as` | Select agent CLI |
| n,x | `<Space>at` | Send position |
| n,x | `<Space>av` | Send selection |
| n | `<Space>ca` | Code action |
| n | `<Space>cd` | Line diagnostics |
| n | `<Space>cf` | Format buffer |
| n | `<Space>cn` | Next diagnostic |
| n | `<Space>cp` | Previous diagnostic |
| n | `<Space>cr` | Rename symbol |
| n | `<Space>dB` | Debug cond. breakpoint |
| n | `<Space>dO` | Debug step out |
| n | `<Space>db` | Debug breakpoint |
| n | `<Space>dc` | Debug continue |
| n | `<Space>di` | Debug step into |
| n | `<Space>do` | Debug step over |
| n | `<Space>dr` | Debug REPL |
| n | `<Space>dt` | Debug terminate |
| n | `<Space>du` | Debug UI |
| n | `<Space>e` | File tree |
| n | `<Space>fb` | Find buffers |
| n | `<Space>fd` | Find diagnostics |
| n | `<Space>ff` | Find files |
| n | `<Space>fg` | Find files and content |
| n | `<Space>fh` | Find help |
| n | `<Space>fr` | Resume picker |
| n | `<Space>fs` | Find symbols |
| n | `<Space>gB` | Blame buffer |
| n | `<Space>gb` | Blame line |
| n | `<Space>gd` | Diff file |
| n | `<Space>gn` | Next hunk |
| n | `<Space>gp` | Previous hunk |
| n | `<Space>gr` | Reset hunk |
| n | `<Space>gs` | Stage hunk |
| n | `<Space>gv` | Preview hunk |
| n | `<Space>n` | Clear search highlight |
| n | `<Space>o` | Only window |
| n | `<Space>q` | Close quickfix |
| n | `<Space>rl` | Rerun last Python command |
| n | `<Space>rr` | Run Python file |
| n | `<Space>rt` | Test Python file with pytest |
| n | `<Space>s` | Horizontal split |
| n | `<Space>t` | Toggle terminal |
| n | `<Space>v` | Vertical split |
| n | `<Space>x` | Close window |
| i | `<Tab>` | Completion next or Tab |
| n | `K` | Hover |
| n,o,x | `S` | Flash treesitter select |
| n,x | `gc` | Toggle comment |
| n | `gcc` | Toggle comment line |
| n | `gd` | Definition |
| n | `gi` | Implementation |
| n | `gr` | References |
| i | `jk` | Normal mode |
| n | `o` | Tree open |
| n | `q` | Tree close |
| n | `r` | Redo |
| n,o,x | `s` | Flash jump |
<!-- keymaps:end -->

See rex/README.md for installation, the complete Ctrl+A keymap, remote
sessions and advanced Lua test automation.
