# tmux terminal type and undercurl

`tmux.conf` sets `default-terminal tmux-256color`. Programs in a pane talk to
tmux, not to the outer terminal, and tmux requires a `tmux`/`screen` entry
there. There is no `ghostty-256color`: Ghostty's own entry is `xterm-ghostty`,
which is `TERM` outside tmux.

The old `default-terminal $TERM` copied whichever client *started the server*
— `xterm-ghostty` from Ghostty, `xterm-256color` from another client — so
the pane `TERM` was effectively random.

Outer-terminal capabilities are negotiated per client by the
`terminal-features` lines (keyed on the client's `TERM`: `xterm-256color*`,
`xterm-ghostty`), so RGB and `usstyle` (undercurl, underline colour) reach
Ghostty regardless of the pane's `TERM`. Verified 2026-09-28: nvim inside a
`tmux-256color` pane emits undercurl (tmux stores `4:3` cells), keeps
`termguicolors` on, and it renders curly in Ghostty inside and outside tmux.

The `ssh()` wrapper in `zsh/.zshrc` pins `TERM=xterm-256color` for remote hosts
that lack `tmux-256color`/`xterm-ghostty` terminfo.

`allow-passthrough on` stays enabled (Kitty graphics protocol for Ghostty).

## Testing without touching the running server

Use a private socket and a minimal conf built from the terminal lines — the
full conf loads continuum/resurrect, which could restore or overwrite
snapshots:

```bash
grep -E '^set.*(default-terminal|terminal-features|terminal-overrides)' ~/.config/tmux/tmux.conf > /tmp/min.conf
env -u TMUX tmux -L t -f /tmp/min.conf new -d -x 60 -y 5 "nvim --clean +'set tgc' +'call setline(1,\"curly\")' +'hi X gui=undercurl' +'call matchadd(\"X\",\"curly\")'"
sleep 2; tmux -L t capture-pane -p -e | grep -c '4:3'; tmux -L t kill-server
```

Parse-check the full conf without running it:
`env -u TMUX tmux -L p -f /dev/null new -d \; source-file -n ~/.config/tmux/tmux.conf \; kill-server`.
