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

Alt+h/j/k/l focuses the pane left/down/up/right, with no prefix. When the
focused pane runs Neovim, Rex writes the Alt key into that pane instead,
so Neovim can move between its own windows first and call rex focus at its
edge. Rex writes the escape sequence itself, so it works whether or not the
Mac client treats Option as Alt.

Ctrl+A is a Rex prefix (press, release, then the next key).
The prefix captures shell Ctrl+A; Ctrl+A twice forwards it to the shell.

| Rex prefix | Action |
| --- | --- |
| h/j/k/l | Focus pane, also from programs that ignore Alt keys |
| r | Resize mode: h/j/k/l resize by 10, Enter or Escape leaves |
| v/s | Split pane right/below |
| z / x | Zoom or close current pane |
| b / f | Balance panes / float pane |
| g / a | Go to any pane / view activity |
| t / n / p | New tab / next tab / previous tab |
| q | Session switcher |
| Tab | Focus previous pane |
| Ctrl+A | Send literal Ctrl+A |

Alt is used instead of Ctrl because shells and agent prompts already use
Ctrl+h/j/k/l (backspace, newline, kill line, clear screen). Programs in
Rex panes no longer receive Alt+h/j/k/l, for example readline Alt+l
(lowercase word) or zsh Alt+h (run-help).

## From Neovim

- :RexSplitRight, :RexSplitBelow create standalone Rex terminals
- :RexAgent opencode, :RexAgent pi, :RexAgent claude launch agents
- :RexRun go test ./... keeps command output in a separate pane
- :RexFocus right, :RexZoom control the current layout
- Space+rr/rt/rl Python actions use Rex when the native context exists

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
4. Run nvim --headless '+luafile nvim/scripts/rex.lua' in the repo.
5. Test Alt+h/j/k/l between shell and Neovim panes, agents, test panes
   and OSC 52 clipboard.
6. If the installed Rex build lacks an action, run rex actions from that
   client and adjust Lua bindings; the beta API can change.

The previous multiplexer configuration was deleted from this repository,
but no command is run to kill or uninstall any service on your VPS.
