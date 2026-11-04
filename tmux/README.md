# VPS tmux

This config keeps Neovim sessions stable through mosh 1.4+, the first
priority of the VPS editor rebuild. Rex is the terminal and multiplexer
on the Mac. RGB means 24-bit color. OSC 52 is a terminal clipboard protocol.
The supported baseline is tmux 3.5a+ and the `tmux-256color` terminfo entry on the VPS.
Rex on the Mac must use a prefix other than Ctrl+a.

## Install and reconnect

1. Back up `~/.tmux.conf`, then link it to this folder's `.tmux.conf`.
2. If a tmux server is running, run `tmux source-file ~/.tmux.conf`.
3. Reconnect with mosh. If the connection already attaches to tmux, stay
   there. Otherwise run `tmux new-session -A -s main`.
4. Confirm `tmux show -gv default-terminal` prints `tmux-256color`.

The verified outer mosh terminal is `xterm-256color`; its RGB capability
is declared explicitly at array index 100, so reloads do not append duplicates.
For a different outer TERM, add its verified RGB capability explicitly. Inside tmux, applications see `tmux-256color`. Escape time is
10 ms. Focus events are enabled, but Neovim must check disk changes on editor
activity because mosh does not reliably carry focus notifications.
`set-clipboard on` forwards OSC 52 copy from Neovim. Paste from the Mac uses
Rex's Cmd+V; OSC 52 clipboard read does not work through mosh.
`on` permits applications in tmux panes to write the client clipboard. The
Neovim rebuild explicitly uses an OSC 52 write provider and local-register
paste; until that PR lands, the existing provider may use tmux buffers.
Avoid relying on `"+p` to read the Mac clipboard.

Graphics passthrough and extended keyboard settings are removed together
with their VPS Neovim consumers. Mosh cannot forward either protocol.

## Keys

Press Ctrl+a, release it, then press the action key.

| Action key | Result |
| --- | --- |
| `d` | Detach, keeping programs running |
| `c` | Create a window |
| `w` | Choose a window |
| `n` / `p` | Next / previous window |
| `[` | Enter copy mode |
| Ctrl+a | Send Ctrl+a to the application |

Use `tmux ls` to list sessions and `tmux attach -t main` to attach.
Mouse scrolling enters copy mode outside an application's alternate screen.

## Verify

1. Run `tmux info` in the attached mosh client; look for RGB or Tc.
2. Run `tmux show -sv escape-time` (expected: `10`),
   `tmux show -gv focus-events` (expected: `on`), and
   `tmux show -sv set-clipboard` (expected: `on`).
3. Copy with Neovim's `"+yy` and paste into a Mac application with Cmd+V.

Acceptance: Esc responds promptly, truecolor works, and copied text reaches
the Mac. This config cannot verify Rex's palette, font, or Mac clipboard.
