# tmux-agent-switcher (fork: MomePP/tmux-agent-switcher)

A Rust/ratatui TUI that runs in a tmux popup, switches between tmux windows, and
shows the live status of AI coding agents running in them. Adopted from
`Ymirke/tmux-agent-switcher` on 2026-08-05 and forked rather than patched
locally, because a TPM clone is throwaway and `prefix + U` overwrites it.

## Where things live

| Path | Role |
|---|---|
| `~/Developer/tmux-plugins/tmux-agent-switcher` | Dev clone. `origin` = the fork; `upstream` = Ymirke, **push URL disabled** on purpose |
| `~/.config/tmux/plugins/tmux-agent-switcher` | TPM's clone, `origin` repointed to the fork. This is what actually runs |
| `tmux/tmux.conf:134` | `set -g @plugin 'MomePP/tmux-agent-switcher'` |

Workflow: edit in the dev clone → push → `git pull` (or `prefix + U`) in the
TPM clone. The launcher rebuilds automatically when `src/` is newer than the
binary, so a stale binary is not a failure mode — but the rebuild happens
*inside the popup* and looks like a hang, so rebuild ahead of time.

**TPM cloned with `--single-branch`**, so its remote refspec only fetches
`main`. A feature branch will never appear no matter how often you fetch until
you widen it:
`git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'`.

**Branch pinning** is `set -g @plugin 'owner/repo#branch'`. Safe even with a
slash in the branch name: `install_plugins.sh` splits on `#` *before* deriving
the directory name, `update_plugin.sh` uses the split part, and
`clean_plugins.sh` walks real directories and substring-matches them against
the raw plugin string.

## What the sidebar is

`sidebar` and `sidebar-right` are two stacked sections; `palette` is unchanged
and still uses the old flat `GridState` list. Every sections-specific code path
is gated on `uses_sections()` — that gate is what makes "palette untouched" true
rather than aspirational.

- **Sessions** (top half): one collapsible row per session with a rolled-up
  agent status dot, name, window count and `▸` for the attached session.
  Expanding reveals its windows as `├─>` tree rows.
- **Agents** (bottom half): one row per window running an agent.
- Fixed half each. Sizing Agents to its content instead put the title just above
  the search bar and moved it whenever an agent came or went, which read as
  drift rather than as a boundary. An empty Agents half says `none running`.
- Top-anchored, deliberately: with two stacked sections a moving boundary is
  worse than dead space below the last row. This retired the old
  bottom-anchored behaviour.
- Agents rows are ordered session-then-window-index and **never by status**.
  Rows that reshuffle when an agent changes state cannot be reliably clicked or
  numbered.

**Keys:** `Tab` focus section · `S-tab` keys/search · `v` cycle view ·
`h`/`l`/`←`/`→`/`C-h`/`C-l` fold · `enter`/`space` open · `C-j`/`C-k` move+open.

## Gotchas that cost real time

**tmux distinguishes "unset" from "set to empty" — but only via `show-options`.**
`show-option -gqv @x` returns `""` for both. `show-options -g @x` *fails* on an
unset option and succeeds on one set to `""`. This is what lets the expansion
set tell "fresh server, seed the attached session" apart from "the user
collapsed everything, honour it". No sentinel token needed.

**tmux hooks are arrays.** Write them at a reserved index
(`set-hook -g 'session-window-changed[50]' …`) — idempotent across the config
reloads that re-run a plugin's `.tmux`, and it leaves other plugins' entries at
other indices alone. A plain `set-hook -g` silently replaces them.
**`after-switch-client` does not exist**; `client-session-changed` is the only
hook for session moves.

**A tmux config reload never unbinds anything.** A plugin that binds keys when
an option is on must *actively unbind* them when it is off, or turning the
option off appears to do nothing until the server restarts. This is why
`@agent_switcher_nav 'off'` left `C-l` switching windows.

**`Modifier::DIM` is not portable.** Stacked on an already-dark grey it washed
a whole section out to barely legible in Ghostty. Step down to a plain dimmer
colour instead. Never dim a status icon — the colour *is* the signal.

**ratatui's `Terminal::clear()` flushes.** It emits its escape through
`execute!`, so the terminal blanks immediately and stays blank until the next
`draw` renders and flushes — a visible blink at any periodic full-repaint
interval. Queue the escape instead (`queue!`) and call `swap_buffers()` to empty
the diff baseline, so the clear and the repaint reach the terminal in one write.

**`run-shell -b` reports a signalled job by taking over the pane.** Killing the
status daemon with `kill` (SIGTERM) makes tmux open a view-mode window showing
`… terminated by signal 15`, which in a session with `status off` looks exactly
like a hang. Retire it gracefully instead: set
`@tmux_agent_switcher_status_daemon_pid` to a bogus value and wait ~3 s — the
daemon checks ownership every 10 polls and exits on its own.

**Counting clippy warnings by `grep -c '^warning'` is wrong.** That counts
per-target summary lines (`generated 1 warning`), which vary with what
recompiles. Use `cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`.

**Agents run under wrappers.** `tmux new -A -s <id> … <cmd>` starts the command
through the login shell, so `pane_current_command` is `nu` and the agent is a
child. Detection walks the pane's process tree rather than trusting the
foreground command. Clone shims (`claude_1`) are matched by accepting `_` as
well as `-` as the separator after the agent name.

**Embedded sessions.** sidekick.nvim's `cli.mux.create = "terminal"` runs
`tmux new -A -s "<tool> <hash>"` inside a Neovim terminal buffer, which gets its
own pty — so the nested client shares neither tty nor window with its host and
tmux reports the session as top-level. They are folded away by tracing each
client's process ancestry back to the pane it was launched from; the session's
agent status rolls up into that host pane's card. A session only folds while
*every* client attached to it is embedded, so it reappears once a real terminal
attaches or it outlives its host.

## Testing conventions

Inline `#[cfg(test)] mod tests` per module; `crate::test_support::test_card`
builds a `WindowCard`. `TestBackend` + `Terminal::new` is the render-test
harness. Tests currently write the developer's live tmux globals via
`persist_expanded`/`persist_session_order` — a known wart, not yet fixed.

`SwitcherUi::with_settings` exists so tests can inject view, input mode and
expansion set instead of inheriting whatever the developer's tmux server holds.
Use it; `SwitcherUi::new` reads real tmux state.

## Known-open follow-ups

- Selected-row highlight spans the full width on session/agent rows but only the
  text width on window child rows.
- `Alt-j`/`Alt-k` on a collapsed session row reorders its active window
  invisibly; arguably should no-op.
- `toggle_expanded`/`collapse_selected` read `sessions_pane` regardless of which
  section has focus.
- Tests still read `TMUX_AGENT_SWITCHER_INITIAL_MOVE` and shell out to
  `load_session_order`.

Next feature designed but not built: the docked sidebar — see
[[tmux-sidebar-dock]].
