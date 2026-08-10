# tmux-agent-dock (fork: MomePP/tmux-agent-dock)

**Renamed from `tmux-agent-switcher` on 2026-08-10**, 58 commits past the fork
point. Repo, package, binary, entry script, launchers, public options,
internal option keys and env vars all moved to `agent_dock`; upstream stays
`Ymirke/tmux-agent-switcher`. Rust type names (`SwitcherUi`, `SwitcherAction`)
were left alone on purpose — internal, compiler-checked, and renaming them is a
naming decision rather than a mechanical one.

**A blanket prefix rename can silently merge two options.** `@agent_switcher_key`
(the popup) and `@agent_switcher_dock_key` (the dock) both collapse to
`@agent_dock_key` under a naive `@agent_switcher_ -> @agent_dock_` swap, which
would have bound whichever was read last to both keys. They are now
`@agent_dock_popup_key` and `@agent_dock_toggle_key`. Diff the option surface
against the docs after any rename: `grep -rho '@agent_dock_[a-z_]*' src *.tmux |
sort -u` against the same over the README.

A Rust/ratatui TUI that switches between tmux windows and shows the live status
of AI coding agents running in them. It runs two ways: as a `display-popup`
(`C-n`) and as a **docked pane** (`prefix + b`) that stays open while you work.
Adopted from `Ymirke/tmux-agent-switcher` on 2026-08-05 and forked rather than
patched locally, because a TPM clone is throwaway and `prefix + U` overwrites it.

## Where things live

| Path | Role |
|---|---|
| `~/Developer/tmux-plugins/tmux-agent-dock` | Dev clone. `origin` = the fork; `upstream` = Ymirke, **push URL disabled** on purpose |
| `~/.config/tmux/plugins/tmux-agent-dock` | TPM's clone, `origin` repointed to the fork. This is what actually runs |
| `tmux/tmux.conf:140` | `set -g @plugin 'MomePP/tmux-agent-dock'` |

Workflow: edit in the dev clone → push → `git pull` (or `prefix + U`) in the
TPM clone. The launcher rebuilds automatically when `src/` is newer than the
binary, so a stale binary is not a failure mode — but the rebuild happens
*inside the popup* and looks like a hang, so rebuild ahead of time.

**A running dock keeps the binary it started with.** Syncing the TPM clone does
not affect the process already in the pane; toggle `prefix + b` off and on to
pick up a new build.

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

- **Sessions** (top, 60%): **one line per row.** A collapsible session row
  carries a rolled-up agent status dot, the name, and the window count plus
  `▾`/`▸` at the right edge. Expanding reveals its windows as `├─>` tree rows.
- **Agents** (bottom, 40%): **two lines per row** — a name line and a
  `working · claude_2` detail line. One row per **agent**, not per window.
- The share is fixed and does not track the agent count: a section that resizes
  itself moves the boundary under the user every time an agent starts or exits.
  40/60 because there are only ever a handful of agents against a tree of
  dozens of rows. An empty Agents section says `none running`.
- Top-anchored, deliberately: with two stacked sections a moving boundary is
  worse than dead space below the last row.
- Agents rows are ordered session-then-window-index and **never by status**.
  Rows that reshuffle when an agent changes state cannot be reliably clicked.

**Row geometry is three functions, and they are the single authority** —
`row_lines(section)`, `header_lines(section)` and `rows_area(area, section)` in
`ui/sections.rs`. The renderer, the click resolver and the scroll clamp all
convert through them. Every off-by-a-row click bug on this plugin came from two
of those three disagreeing, so add nothing that computes row offsets itself.

Each section's header is three lines: a leading line, the title, a blank. The
leading line is the horizontal rule for Agents (the only thing marking the
boundary) and is left blank for Sessions.

**Visual grammar:**

| Signal | How it is said |
|---|---|
| Cursor row | White **and bold**, over everything — but **only while that surface holds the keyboard**. `focus` is an `Option<SectionFocus>`; `None` means the keys are elsewhere and no cursor is drawn. A dock spends most of its life beside the pane you are typing in, where a cursor claims a selection no key would act on and competes with the accent for the question the sidebar answers: where am I. Not a slab — neither `REVERSED` nor a filled background: both were tried, and across a 30-column sidebar of thin tree punctuation a bar pulls harder than the name it marks |
| Session name | White. The tree is scanned by session first, so the names that anchor it stay bright |
| Window row | `Color::DarkGray`, receding under its session |
| Attached session or window | The accent colour, since the right edge now belongs to the fold arrow |
| An agent that finished out of sight | The unread dot. "Out of sight" is the whole meaning of it: the daemon marks a pane read whenever it is visible — its window is its session's current one *and* something is attached to that session. So an agent you sat and watched finish never raises one, and a sidekick agent that finished behind a closed float does. Before this the dot was raised by the `Working → Idle` edge alone and could only be cleared by selecting the row you were already looking at |
| Rolled-up status on a session | Its dot — but **only while collapsed**. Expanded, every window under it shows its own, and a dot beside an open session reads as the session being the busy thing. The column stays blank so names still line up |
| Detail line | `Color::DarkGray` |
| Agent state | The status icon's colour, which is **never** dimmed — the colour *is* the signal |
| Section focus | Nothing. Dimming the unfocused half made the sidebar look switched off; the cursor already says it |

**Keys:** `Tab` focus section · `S-tab` keys/search · `v` cycle view ·
`h`/`l`/`←`/`→`/`C-h`/`C-l` fold · `enter`/`space` open · `C-j`/`C-k` move+open.

## The docked sidebar

`prefix + b`. A pane, not a popup — it stays while you work in the pane beside
it, and it follows you between windows and sessions.

**The constraint that shapes it: a tmux pane belongs to exactly one window.**
There is no pane that persists across a window switch. So "always visible" is
built, not declared, and there were only three ways to build it — one pane
relocated by a hook (chosen), a sidebar pane in every window (one TUI process
per window, ~21 here, each redrawing on the refresh tick), or a workspace window
that targets get `join-pane`d into (erodes the window structure as you work).

**Two things move it, and the difference is visible.** A switch the switcher
performs itself — clicking or hitting enter on a row, in the dock or the popup —
puts the move *in front of* the switch in one tmux invocation (`select_card` →
`dock::carry_before_switch`): guard, remember the destination's geometry, move
the dock, restore the window being left, switch, select, release. tmux runs the
list in one pass and redraws once, so the first frame of the destination already
has the sidebar in it. A switch made any other way — a prefix binding, herdr,
plain `select-window` — is caught by the follow hook instead, which by
definition runs *after* the client has already moved.

That asymmetry is the durable lesson: **a hook that fires after the client moves
can never prevent the first wrong frame.** The destination gets drawn full
width, and the sidebar arrives a beat later once the hook's own process has
forked and probed. Making the hook faster does not help; only putting the move
ahead of the switch does. Both paths share `carry_args` + `release_guard_args`,
with the guard deliberately left up in between so a caller can splice its own
commands inside the same invocation.

State lives in tmux options so the `.tmux` script, the hooks and the binary
agree without a side channel:

| Option | Scope | Holds |
|---|---|---|
| `@tmux_agent_dock_pane` | global | The dock's `pane_id`, unset when closed |
| `@tmux_agent_dock_moving` | global | Re-entry guard while a move is in flight |
| `@tmux_agent_dock_client` | global | The client the dock belongs to |
| `@tmux_agent_dock_layout` | window | The host window's `window_layout` from before the dock arrived |
| `@agent_dock_width` | global | Columns, default 30 |

**Opening:** save `#{window_layout}`, `split-window -b -h -d -l <width>` running
`tmux-agent-dock dock`, record the `pane_id`.
**Following:** hooks at reserved index `[50]` on `session-window-changed` and
`client-session-changed` run `dock-follow`, which `move-pane -b -h -d`s the dock
into the newly active window. `-d` leaves it inactive, so the hook never steals
focus.
**Closing:** `prefix + b` again — and nothing else. Kill the pane, restore the
host window's layout, unset the global.

`Esc` and `q` deliberately do **not** close the dock. They keep their useful
half and lose the fatal one: `Esc` clears the query, and with an empty query
both move focus to the work pane. In the popup, closing is harmless; in the dock
a stray `Esc` mid-navigation would tear down the window layout.

Three hazards, each with a specific answer:

- **Hook recursion.** `move-pane` changes the active window and re-fires the
  same hooks. `_dock_moving` is set before the move and cleared after; a hook
  that sees it returns immediately.
- **Layout damage.** If panes were created or destroyed while the dock was
  there, the saved `window_layout` string no longer matches the pane set and
  `select-layout` fails. The failure is **ignored** — restoring geometry is a
  courtesy, not a guarantee worth erroring over.
- **Stale pane id.** If the recorded pane is gone (killed directly, server
  restarted), the toggle treats the dock as closed and opens a fresh one.

The dock builds its argv through pure functions (`split_args`, `move_args`,
`restore_layout_args` in `dock.rs`) so flag order and the load-bearing `-d` are
pinned by unit tests rather than by a shell script nobody re-reads.

**Mouse.** tmux's default root binding is
`MouseDown1Pane → select-pane -t = ; send -M`, so one click both focuses the
dock and forwards the event. No new binding, no double-click. A click on a
section header or past the last row focuses that section without selecting —
clicking empty space should not teleport you.

## Agent detection and embedded sessions

**Agents run under wrappers.** `tmux new -A -s <id> … <cmd>` starts the command
through the login shell, so `pane_current_command` is `nu` and the agent is a
child. Detection walks the pane's process tree rather than trusting the
foreground command. Clone shims (`claude_1`) are matched by accepting `_` as
well as `-` as the separator after the agent name.

**Embedded sessions.** sidekick.nvim's `cli.mux.create = "terminal"` runs
`tmux new -A -s "<tool> <hash>"` inside a Neovim terminal buffer, which gets its
own pty — so the nested client shares neither tty nor window with its host and
tmux reports the session as top-level. They are folded away by tracing each
client's process ancestry back to the pane it was launched from. A session only
folds while *every* client attached to it is embedded, so it reappears once a
real terminal attaches or it outlives its host.

**One host pane can hold several agents.** `<leader>s` and `2<leader>s` spawn
`claude_1` and `claude_2` from the same Neovim. `WindowCard.folded_agents` is a
`Vec<FoldedAgent>` for exactly this reason — an earlier `Vec<String>` of pane
ids discarded per-agent identity and status, so the Agents section showed one
row carrying their rollup and the second agent was invisible.

**Focusing a specific agent goes through Neovim's RPC, not keystrokes.**
`SwitcherAction::SelectAgent { card, clone }` carries the clone name because a
card is a *window* and the whole problem is one window holding several agents.
`nvim.rs` finds the socket (nvim writes its pid into the filename —
`$TMPDIR/nvim.<user>/<rand>/nvim.<pid>.0` — so the process walk already done for
embedded detection finds it) and calls

```lua
require('sidekick.cli').show({ name = <clone>, filter = { cwd = true }, focus = true })
```

`show` and not `toggle`: it is idempotent, reveal-and-focus, and takes the clone
by name. Send-keys is disqualified because the user's `<leader>s` binding ends
in `cli.toggle(...)` — a flip, which hides an already-open float as often as it
reveals one. Keystrokes can only say "flip"; the dock needs "show". The Lua runs
inside `pcall`, and every failure (no socket, no nvim, sidekick not loaded
there, renamed API) falls back to focusing the host pane.

**Driving the switcher from inside a sidekick float caused recursive attach.**
The client living in the float belongs to the *embedded* session; switching it
to its own host session makes tmux render recursively — jumping, broken layout.
`embed::outer_client_tty()` resolves the outermost non-embedded client and every
dock command targets that. Getting this half-right is easy and useless: the host
*window* must be resolved **and** the `split-window` must be `-t`-targeted at it.

## Gotchas that cost real time

**`Color::Gray` is SGR 37 — the terminal's *normal* white.** On a dark theme it
is indistinguishable from `Color::White`, so a "dimmed" line asking for it
renders undimmed. `DarkGray` is SGR 90 and is the one that reads as grey.
`Color::Black` vanishes into the background entirely. This wasted three rounds
of "the detail line is still too bright / now it's invisible".

**A dock pane renames its host window under `automatic-rename`.** tmux names a
window after its *active* pane, and this user's
`automatic-rename-format` is `#{b:pane_current_path}` — a directory. The dock is
a pane and inherits its cwd at spawn, so clicking into the sidebar renamed the
window to `basename $HOME` and it reverted on blur. `dock::match_host_cwd`
chdirs the dock process to the **active** neighbouring pane's directory, which
makes the rename a no-op. Turning `automatic-rename` off on the host window
would instead freeze the name of whichever window you are working in, and
overrides a setting the user chose.

**Nothing the dock knows about itself survives being read once.** It is a
long-lived process that tmux moves between windows underneath it, so every
"where am I" answer goes stale: its window (which is *the attached window*,
since it follows — that is what the accent marks), whether its pane holds the
keyboard, and its directory. A popup can read these at startup because it lives
for seconds; a dock lives for hours, and the accent stayed on whichever window
it was opened in for the rest of the day. `dock::observe` re-reads all three per
tick from one `list-panes`.

Four things about the cwd match are load-bearing, each learned the hard way:

- **The dock must be `exec`'d, or none of the rest matters.** tmux runs a pane
  command through `default-shell`, so `split-window "<exe> dock"` makes the
  pane's process `nu -c <exe> dock` with the dock a *child* of it — and
  `pane_current_path` comes from the pane's own process. Every `set_current_dir`
  the dock made was invisible; its reported directory stayed frozen at whatever
  the pane it was split from was in. `split-window "exec <exe> dock"` replaces
  the shell with the binary. Symptom that finally exposed it: the dock sat in
  the `nvim` window for 600ms still reporting `~/.config`, and the click that
  made it the active pane renamed that window `.config`. **When a chdir seems to
  have no effect on a tmux format, check whether the process you changed is the
  pane's process.**
- **Match the *active* neighbour, not the first one.** The name is computed from
  the active pane; in a three-pane window "first non-dock pane" copied the wrong
  directory two times in three.
- **Match *after* the move, never before.** While the dock is still in the
  window it is leaving, changing its directory renames *that* window. Same bug,
  other end.
- **A tick is too late.** tmux applies the rename ~250ms after the active pane
  changes (measured), so a match that waits for the 300ms card tick is a visible
  flicker: the window wears its neighbour's name and hands it back. Match
  synchronously when the dock performs a switch, and on `Event::Resize`, which is
  how the dock learns the follow hook carried it — a hook in another process
  cannot `chdir` the dock's process for it.

**The dock must not do the popup's work.** The TUI loop is shared, so anything
unconditional in it runs in both surfaces. Refreshing the preview was: the dock
draws none, but `PreviewMirror::refresh_for` re-captures whenever the selection
changes, so every `j`/`k` shelled out to `capture-pane` for panes nothing would
render — a stall exactly where it is most visible. It also measured the capture
with `switcher_layout`, the popup's geometry. Gate surface-specific work on
`surface == Surface::Popup`.

**`Modifier::DIM` is not portable.** Stacked on an already-dark grey it washed a
whole section out to barely legible in Ghostty.

**`display-message -p -c <client>` does not scope format expansion.** `-c`
chooses the client a message is *shown* to. With `-p` the format is expanded
against whichever client tmux picks for itself — the most recently used one — so
asking three different ttys "which window are you in?" returns the same answer
three times. Verified on 3.7b: with a sidekick float last touched, every `-c`
reported the float's window, and the dock followed itself inside the embedded
session. **To ask a specific client, use `list-clients -F`**, which expands its
format in each client's own context and answers for all of them in one call:
`#{client_tty}\t#{session_name}\t#{window_id}\t#{pane_id}\t#{window_width}\t#{window_layout}`.
`-c` on a command whose *subject* is a client (`switch-client -c`) is a different
thing and is honoured.

Corollary for finding this class of bug: **a read-only smoke test of a hook,
run from outside any client, is worth more than it looks.** Outside a client is
where tmux's "pick a client for me" fallback is most wrong, so it exposes
exactly the assumptions that hold by luck inside one.

**`nvim --remote-expr` waits for the *editor*, not the client.** The client
binary starts in ~14ms; the RPC then blocks until the expression finishes
running inside the target Neovim, and `sidekick.cli.show` opening a float and
attaching a terminal takes a second or two. Anything sequenced after it — the
dock's re-observe and redraw — inherits that wait, which is why the accent
landed long after the window it describes had changed. The reveal is best
effort, so it is started and not waited for.

Getting "don't wait" right across both surfaces needs a **process**, not a
thread: the popup exits immediately after asking, and only a separate process
survives that; the dock lives on, so something must `wait()` on the child or
every click leaves a zombie. A thread doing the waiting satisfies both. Give the
child its own process group as well — the popup runs under `display-popup -E`,
which tmux tears down when the command exits.

**A pane cannot be padded, and `pane-scrollbars` is not the loophole.** tmux 3.7
added scrollbars with a `pad` in `pane-scrollbars-style`, and set to
`position left` they really do reserve columns — measured, a plain shell's
content moved from column 41 to 42. But tmux only reserves them for panes with
scrollback: the moment a pane enters the **alternate screen** the reservation
vanishes (41 again). Every pane worth padding here — nvim, the dock's own TUI —
is `alternate_on=1`, so it does nothing for them, and on a plain shell it makes
the content jump a column whenever an editor opens or closes. The rule stands: a
column is only blank if some pane owns it and paints it blank, so the space
either side of a split can only come from the panes themselves, never from tmux.

**tmux hooks are arrays.** Write them at a reserved index
(`set-hook -g 'session-window-changed[50]' …`) — idempotent across the config
reloads that re-run a plugin's `.tmux`, and it leaves other plugins' entries at
other indices alone. A plain `set-hook -g` silently replaces them.
**`after-switch-client` does not exist**; `client-session-changed` is the only
hook for session moves.

**A tmux config reload never unbinds anything.** A plugin that binds keys when
an option is on must *actively unbind* them when it is off, or turning the
option off appears to do nothing until the server restarts. This is why
`@agent_dock_nav 'off'` left `C-l` switching windows.

**tmux session names accept `:`, `.` and `!`** (verified on 3.7b), so there is
no character an in-band marker can safely use when encoding session names into
an option value. Use a second option instead.

**ratatui's `Terminal::clear()` flushes.** It emits its escape through
`execute!`, so the terminal blanks immediately and stays blank until the next
`draw` renders and flushes — a visible blink at any periodic full-repaint
interval. Queue the escape instead (`queue!`) and call `swap_buffers()` to empty
the diff baseline, so the clear and the repaint reach the terminal in one write.
This bit twice: once in the periodic repaint, then again in `Event::Resize`,
which had been left behind when the first was fixed.

**`run-shell -b` reports a signalled job by taking over the pane.** Killing the
status daemon with `kill` (SIGTERM) makes tmux open a view-mode window showing
`… terminated by signal 15`, which in a session with `status off` looks exactly
like a hang. Retire it gracefully instead: set
`@tmux_agent_dock_status_daemon_pid` to a bogus value and wait ~3 s — the
daemon checks ownership every 10 polls and exits on its own.

**A pane's width does not survive its window being resized.** `move-pane -l 30`
sets the width once and nothing re-asserts it; tmux rescales every pane in a
window whenever the window's own size changes, and each window is sized to the
last client that looked at it, so windows resize constantly under a single
client. Measured on 3.7b: a 30-column pane in a 200-column window squeezed to
120 columns is crushed to **1**, and grown back to 200 comes out **41**. Any
fixed-width pane has to hold its own width. `dock::keep_width` does it from
inside the dock — the process already knows its width, because the terminal it
draws into *is* the pane — on the same tick that refreshes cards, and only when
the width has just changed, so a window with no room to spare is asked once and
not again.

**Folding needs a client, and closing a sidekick float takes it away.**
`embed::resolve_embedded` traces *attached clients* back to a host pane. Close
the float and the client detaches, but `tmux new -A -s` keeps the session
running — no client, nothing to trace, and the session reappeared in the sidebar
as a peer with its Neovim showing no agent. The mapping is therefore remembered
in `@tmux_agent_dock_embedded` (`session\tpane` per line) and kept while all
three still hold: the session exists, the host pane exists, and that pane belongs
to some *other* session. The last clause does double duty — it rules out folding
a session into itself, and it is what expires the memory when the Neovim's pane
is gone, which is the case embed.rs always wanted right: a session that outlives
its host goes back to standing on its own. A live client outranks the memory; a
real terminal attachment discards it.

**A retiring status daemon must not clear the winner's claim.** Retiring by
handoff is the only safe way to replace one (see the `run-shell -b` entry
above), but the old code unset `@tmux_agent_dock_status_daemon_pid` on exit
*unconditionally* — including when the replacement had already claimed it.
`ensure_status_daemon` then saw an empty option and started another daemon,
which took the option, which retired the incumbent, which cleared it again.
Once two daemons ever coexisted the pair never settled: a new process every few
seconds for the life of the tmux server, and it is invisible unless you watch
the pid. Release the option only while it still names you.

**Counting clippy warnings by `grep -c '^warning'` is wrong.** That counts
per-target summary lines (`generated 1 warning`), which vary with what
recompiles. Use `cargo clippy --all-targets 2>&1 | grep '^warning' | grep -vc 'generated'`.

## Persisted state

Everything sticky lives in global tmux options for the server's lifetime, and
all writes go through `ui::mod::set_global_options`, which chains them into one
`set-option` invocation so a reader can never catch a related pair
half-applied — and is a **no-op under `cfg(test)`**.

That guard is load-bearing, not tidiness. The unit tests drive the very keys
that persist (`v`, `S-tab`, `h`, `l`) against fixture data, so without it a
plain `cargo test` rewrites the developer's own live tmux globals. It really
happened: a test run set `@tmux_agent_dock_known` to `dotfiles`, a session
that exists only in `sections::tests::fixture`, on a server with no such
session.

**Expansion state is two sets, not one.** `@tmux_agent_dock_expanded` is
what was left open; `@tmux_agent_dock_known` is every session the switcher
had an opinion about at close. A session in `known` keeps whatever it was left
as; a session in neither is new and follows
`@agent_dock_expand_default` (`all` — the default — / `attached` / `none`).

Remembering only `expanded` conflated "you collapsed this" with "this did not
exist yet", which broke two things: a session created since the last close
always opened folded, and a remembered set that had gone empty left *everything*
collapsed forever with no way back but unsetting the option by hand. An earlier
fix distinguished unset from set-to-empty (`show-options -g` fails on unset
while `show-option -gqv` returns `""` for both) — that trick is **retired**; it
addressed the symptom and the two-set memory addresses the cause.

## Testing conventions

Inline `#[cfg(test)] mod tests` per module; `crate::test_support::test_card`
builds a `WindowCard`. `TestBackend` + `Terminal::new` is the render-test
harness. `SwitcherUi::with_settings` injects view, input mode and the remembered
expansion pair so tests do not inherit the developer's tmux server; use it,
because `SwitcherUi::new` reads real tmux state.

**What unit tests cannot cover, and how it was actually checked.** Hook
behaviour, the dock's real geometry and the mouse path need a live server. The
technique that worked: `pty.fork()` a client attached to an isolated
`tmux -L <name>` server, `ioctl(TIOCSWINSZ)` it to a realistic size, drive the
dock via `tmux run-shell` (the same route the keybinding takes), and read the
result back with `capture-pane -p -e`. Mouse clicks go in as SGR sequences
(`\x1b[<0;<col>;<row>M`) written to the pty fd — **calibrate the row offset
empirically** rather than assuming, by clicking a sweep of rows and watching
which one goes bold.

Two harness false alarms burned real time: a checklist run with **no attached
client** produced five phantom failures, and a stray copied binary broke a
`pane_current_command` grep. Suspect the harness before the code when a live
check disagrees with a green unit suite.

## Known-open follow-ups

- Selected-row highlight spans the full width on session/agent rows but only the
  text width on window child rows.
- `Alt-j`/`Alt-k` on a collapsed session row reorders its active window
  invisibly; arguably should no-op.
- `toggle_expanded`/`collapse_selected` read `sessions_pane` regardless of which
  section has focus.
- Tests still read `TMUX_AGENT_DOCK_INITIAL_MOVE` and shell out to
  `load_session_order`.
- With two clients attached to different windows the dock follows whichever
  moved last. Single-client is the documented assumption.
- The dock branch never got a final whole-branch review — subagent dispatch was
  denied mid-plan, so tasks 3–7 carry controller-performed reviews only.

## Neighbours that the dock disturbs

**sidekick.nvim floats do not survive a resize.** `Terminal:open_win` resolves a
float's fractional size to absolute rows and columns *once*
(`opts.width = opts.width <= 1 and floor(vim.o.columns * w)`), and the plugin
registers no `VimResized` handler. An `editor`-relative float keeps whatever
geometry it opened with — nvim clamps floats down to fit a shrinking editor but
never grows them back. Verified headless: editor 80→200 columns leaves the float
at 80.

So opening the dock (narrowing the nvim pane), toggling a sidekick float, then
closing the dock leaves the float at the narrow width with stale cells to the
right of it. Nothing tmux does fixes this — the stale cells are inside nvim's own
grid. The fix is a `VimResized` autocmd in `nvim/lua/plugins/llm-config.lua` that
re-applies sidekick's own arithmetic and writes the geometry over the window's
*current* config, so the border, footer and title from `cli.win.config` survive.

## Prior art

[[tmux-agent-sidebar]] records the original evaluation of the upstream plugin
and the gaps that motivated this fork.
