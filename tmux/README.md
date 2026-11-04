# VPS tmux

This config serves priority 1: stable Neovim sessions through mosh 1.4+.
It requires tmux 3.5a+ and the `tmux-256color` terminfo entry on the VPS.
Rex on the Mac must use a prefix other than Ctrl+a.

## Install and reconnect

1. Back up `~/.tmux.conf`, then link it to this folder's `.tmux.conf`.
2. Run `tmux source-file ~/.tmux.conf`.
3. Reconnect with mosh and run `tmux new-session -A -s main`.
4. Confirm `tmux show -gv default-terminal` prints `tmux-256color`.

The outer mosh terminal is `xterm-256color`; its RGB capability is declared
explicitly. Inside tmux, applications see `tmux-256color`. Escape time is
10 ms. Focus events are enabled, but Neovim must also reload without them.
`set-clipboard on` forwards OSC 52 copy from Neovim. Paste from the Mac uses
Rex's Cmd+V; OSC 52 clipboard read does not work through mosh.

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
2. Confirm `escape-time` is 10, `focus-events` is on, and `set-clipboard`
   is on with `tmux show -s` or `tmux show -g` as appropriate.
3. Copy with Neovim's `"+yy` and paste into a Mac application with Cmd+V.

Acceptance: Esc responds promptly, truecolor works, and copied text reaches
the Mac. This config cannot verify Rex's palette, font, or Mac clipboard.
