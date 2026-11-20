# Rex as the only terminal multiplexer

The intended architecture: Rex macOS client -> SSH -> Linux Rex Server.
Sessions persist on the remote server when configured to run at boot.
Each Rex pane contains an independent terminal, while Neovim buffers and
editor windows live inside one terminal pane.

Rex Linux Server is in testing and may require beta access. Follow the
official documentation rather than assuming a package is publicly available:

- https://www.superlogical.com/rex/docs/installation
- https://www.superlogical.com/rex/docs/linux/installation
- https://www.superlogical.com/rex/docs/linux/remote-access
- https://www.superlogical.com/rex/docs/reference/cli
- https://www.superlogical.com/rex/docs/automate/lua-scripts

## Install and connect

Install Rex on Mac, then use its interactive remote installer:

    rex server install ssh://USER@VPS_HOST --label vps
    rex -S vps ls

Replace USER and VPS_HOST with your SSH login. This command asks before
remote changes. Alternatively install Rex on Linux from the authenticated
instructions, then run rex server install as the VPS user. Verify:

    ssh USER@VPS_HOST rex version
    rex -S ssh://USER@VPS_HOST ls

In Rex for Mac choose Add Remote Host and the ssh:// URL. SSH keys are
reused; do not expose a plain HTTP Rex endpoint. A persistent personal
server requires systemd user linger, configured by rex server install.
Do not remove existing sessions until you have tested reconnects.

## Lua configuration

Link this repo's rex/init.lua to ~/.config/rex/init.lua on each host where
the Rex server runs. Run on that host, not via a remote reload command:

    rex config check ~/.config/rex/init.lua
    rex config reload

The CLI inside a native Rex terminal has REX_BLOCK and targets the right
session/block. An ordinary SSH subprocess in a Mac-local pane is not the
same thing as a remote Rex session.

## Keyboard shortcuts

Ctrl+Shift+h/j/k/l focuses the pane left/down/up/right, with no prefix. When
the focused pane runs Neovim, Rex lets the key through to that pane instead,
so Neovim can move between its own windows first and call rex focus at its
edge. On the Ferris Sweep, hold A (Shift) and D (Ctrl), then tap the letter.

The iPad app (Rex Dev 0.1.0, build 1971) does not apply these bindings: it
sends every key straight to the pane. There Ctrl+Shift+h/j/k/l still works
from Neovim panes, because Neovim maps the same keys; in shell and agent
panes, tap the pane instead.

Ctrl+A is a Rex prefix (press, release, then the next key).
The prefix captures shell Ctrl+A; Ctrl+A twice forwards it to the shell.

| Rex prefix | Action |
| --- | --- |
| h/j/k/l | Focus pane, also from programs that ignore Ctrl+Shift+h/j/k/l |
| c / o / i | Claude / opencode / pi agent pane to the right |
| e | Toggle the floating scratch shell |
| r | Resize mode: h/j/k/l resize by 10, Enter or Escape leaves |
| v/s | Split pane right/below |
| z / x | Zoom or close current pane |
| b / f | Balance panes / float pane |
| g / a | Go to any pane / view activity |
| t / n / p | New tab / next tab / previous tab |
| q | Session switcher |
| Tab | Focus previous pane |
| Ctrl+A | Send literal Ctrl+A |

Ctrl+Shift is used because the other modifiers are taken:

- Option types letters on the Polish Pro layout (Option+l is ł, Option+n is
  ń), so no Rex key uses Option, and every Option key reaches the pane.
- Plain Ctrl+h/j/k/l already mean backspace, newline, kill line and clear
  screen in shells and agent prompts.
- iPadOS reserves Cmd+H for the Home screen.

Programs in Rex panes other than Neovim no longer receive
Ctrl+Shift+h/j/k/l.

## Actions

rex/init.lua defines three actions. They appear in the Rex command
palette, run from the CLI, and Neovim calls them; each new pane starts in
the cwd argument, else in the directory of the pane's foreground program.

| Action | What it does | Keys |
| --- | --- | --- |
| agent name=claude/opencode/pi | Agent pane to the right, 40% | Ctrl+A c / o / i |
| run cmd=... | Command pane below, 30%, stays open after exit | |
| scratch | Toggle one floating shell per window; hiding keeps it running | Ctrl+A e |

    rex do run cmd="pytest -x" cwd="$HOME/project"

## From Neovim

- :RexAgent opencode, :RexAgent pi, :RexAgent claude call the agent action
- :RexRun go test ./... calls the run action with the editor CWD
- Space+rr/rt/rl Python actions call the run action
- Space+t calls the scratch action
- Splits and zoom are Rex keys only (Ctrl+A v/s/z); Ctrl+Shift+h/j/k/l
  moves between Neovim windows and on to Rex panes

## Editor: Rex switches files, Neovim edits

Rex owns window and file switching; Neovim is left to edit text. Rex starts
one Neovim per project root with `--listen` and afterwards drives it over that
socket, so nvim/ needs no configuration for this and stays a plain checkout.
The editor pane is labelled `editor:<project>`.

| Key | Action | VS Code equivalent |
| --- | --- | --- |
| Ctrl+Shift+p | Pick a file and open it | Cmd+P quick open |
| Ctrl+Shift+b | Pick an open buffer | editor dropdown |
| Ctrl+Shift+n / Ctrl+Shift+m | Next / previous buffer | Cmd+Tab / Cmd+Shift+Tab |
| Ctrl+Shift+f | Search the project, pick a match | Cmd+Shift+F |

`edit` lists tracked and untracked files, honouring `.gitignore`, and falls
back to `find` outside Git. `search` needs ripgrep. The first open splits an
editor pane at 60%; later opens reuse it and focus it.

Each action takes its argument so scripts never block on a prompt:

    rex do edit path=src/main.py cwd="$HOME/project"
    rex do buffer_cycle direction=prev
    rex do search pattern=TODO

Ctrl+Shift+p, Ctrl+Shift+b, Ctrl+Shift+n, Ctrl+Shift+m and Ctrl+Shift+f belong
to Rex, so programs in panes no longer receive them. They need a client that
applies Rex bindings; on the iPad, use Space+ff, Space+fg and Space+fb in
Neovim instead.

Telescope and nvim-tree stay bound inside Neovim. Stop using Space+ff, Space+fg
and Space+e if file switching should come from Rex alone.

## Advanced Lua automation

In a Rex terminal within the project checkout:

    rex do ./rex/scripts/test-watch.lua cmd="go test ./..."

This uses Rex's native Lua layout and event APIs. It runs tests in a
separate pane without changing focus, waits up to ten minutes and zooms
the result only if tests fail. No additional plugin or subscription needed.

## Deployment checks

1. Confirm rex version and rex config check on Mac and VPS.
2. Open the remote host from Rex for Mac and create a persistent session.
3. Disconnect/reconnect; confirm the programs are still there.
4. Run nvim --headless '+luafile nvim/scripts/rex.lua' and
   python3 rex/scripts/check_config.py in the repo. The second starts a
   throwaway Rex server with this init.lua; it never touches the running one.
5. Test Ctrl+Shift+h/j/k/l between shell and Neovim panes, agents, test
   panes and OSC 52 clipboard.
6. If the installed Rex build lacks an action, run rex actions from that
   client and adjust Lua bindings; the beta API can change.

The previous multiplexer configuration was deleted from this repository,
but no command is run to kill or uninstall any service on your VPS.
