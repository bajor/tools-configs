# tmux for Neovim on the VPS

The canonical Neovim configuration is [nvim/](../nvim/).
Connection: Mac (Rex) → mosh 1.4+ → Ubuntu VPS tmux 3.5a+ → Neovim.
Tmux owns persistent remote terminal panes; Neovim owns editor windows.
No nested tmux and no Neovim/tmux navigation plugin are needed.

## Install and reconnect

1. Back up `~/.tmux.conf`, then link it to this repository's `tmux/.tmux.conf`.
2. Verify configuration parsing in an isolated tmux server:
   `tmux -L config-check -f tmux/.tmux.conf new-session -d -s config-check`
   then `tmux -L config-check kill-server`.
3. Reload a live session using `tmux source-file ~/.tmux.conf`.
4. Connect via mosh, then `tmux new-session -A -s main` if not attached.

All bindings use **Ctrl+a** as tmux prefix (press, release, then action).
This leaves unprefixed Ctrl+h/j/k/l available for shell line editing,
including backspace, newline, kill-line and clear-screen. Avoid giving Rex
the same prefix.

## Pane keys

| Keys | Action |
| --- | --- |
| `Ctrl+a h/j/k/l` | Focus pane left/down/up/right |
| `Ctrl+a v` | Split terminal to the right in the current directory |
| `Ctrl+a s` | Split terminal below in the current directory |
| `Ctrl+a H/J/K/L` | Resize left/down/up/right by five cells |
| `Ctrl+a z` | Zoom/unzoom pane (tmux default) |
| `Ctrl+a Tab` | Return to previous pane |
| `Ctrl+a x` | Confirm pane closure (tmux default) |
| `Ctrl+a c` | New window |
| `Ctrl+a w` | Window chooser |
| `Ctrl+a n/p` | Next/previous window |
| `Ctrl+a d` | Detach while keeping session running |
| `Ctrl+a [` | Copy mode |
| `Ctrl+a r` | Reload `~/.tmux.conf` |
| `Ctrl+a Ctrl+a` | Send Ctrl+a into program |

## Seamless navigation from Neovim

**Space+h/j/k/l** moves between Neovim editor windows. If no editor window
exists in that direction, Neovim asynchronously runs the matching
`tmux select-pane` operation, only if it is inside a tmux session.
No adjacent tmux pane means no focus change.

In shell, Pi, OpenCode or test panes, use **Ctrl+a h/j/k/l** to navigate
back to the editor. Tmux never intercepts the shell's unprefixed Ctrl keys.
Neovim terminal-mode Ctrl+h/j/k/l exits terminal input and uses the same
editor-window-to-tmux edge fallback.

**Space+v/s** makes Neovim editor windows. **Ctrl+a v/s** makes independent
tmux terminals. Both split directions are relative to the focused pane.

## Mosh, colors and clipboard

The setup retains `tmux-256color`, truecolor capability for `xterm*`,
`escape-time=10`, focus events, 100k scrollback, mouse support, and
Solarized Dark – Vivid colors shared with the Neovim theme.

OSC 52 can **write** the Mac clipboard through mosh 1.4+ and tmux.
Clipboard **reads** cannot work across mosh, so `"+p` in Neovim uses
its unnamed register. To paste the Mac clipboard, use Cmd+V in Rex.
Extended-key input, graphics and focus notifications are constrained by mosh.

## Verify on the VPS

```bash
tmux show -gv default-terminal
tmux show -sv escape-time
tmux show -gv focus-events
tmux show -sv set-clipboard
nvim --headless '+luafile nvim/scripts/tmux.lua'
```

Expected: `tmux-256color`, `10`, `on`, `on`, and a passing Neovim
navigation smoke test. Check pane directions, working directories, and
OSC 52 copying interactively from the actual VPS/mosh/Rex session.
