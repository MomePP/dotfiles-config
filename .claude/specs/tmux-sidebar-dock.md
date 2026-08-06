# tmux-agent-switcher: the docked sidebar

Design for a persistent sidebar that lives in a real tmux pane, travels with you
as you move between windows and sessions, and is driven by the mouse — so you
can pick a target and immediately work in it without closing anything.

Target: `MomePP/tmux-agent-switcher`. Builds on the two-section Sessions+Agents
sidebar from [[tmux-sidebar-sections]], and finally closes gaps 1 and 2 that
[[tmux-agent-sidebar]] §3.1 recorded against the upstream plugin.

**Status: designed, not implemented.**

---

## 1. Why

Today the switcher is a `display-popup`. That makes it modal by construction:
it owns the keyboard, it covers the screen, and it exits when you pick
something. The preview pane shows you a window but you cannot type into it —
"like a preview to check, but cannot be focused".

herdr's sidebar is a different thing: it stays on the left while you work on the
right, and you click it to move around. Reproducing that in tmux means the
sidebar has to stop being an overlay and become a pane.

## 2. The constraint that shapes everything

**A tmux pane belongs to exactly one window.** There is no pane that persists
across a window switch, and no popup that passes keystrokes through to what is
behind it. So "always visible" cannot be declared — it has to be built, and
there are only three ways to build it.

| Model | How | Rejected because |
|---|---|---|
| **Follows you** (chosen) | One pane, relocated into the active window by a hook | — |
| Everywhere at once | A sidebar pane in every window | One TUI process per window — ~21 here — each redrawing on the refresh tick |
| A workspace window | Sidebar pinned in one window; targets `join-pane`d to it | Pulls panes out of their home windows; the existing window structure erodes as you work |

## 3. Decisions

| Decision | Chosen | Rejected, and why |
|---|---|---|
| Presence | One pane that follows you | See §2 |
| Toggle | `prefix + b` | — (user-specified; verified unbound in both tmux defaults and the user's config) |
| The `C-n` popup | Unchanged | Retiring it — not asked for, and it is a working surface |
| Focus after selecting | Lands in the work pane | Staying in the sidebar — makes "go there and work" two actions |
| Follow rule | Every window/session change, however it was caused | Only sidebar-initiated moves — one `prefix+n` and "always visible" is already a lie |
| Preview pane in the dock | None | The work pane to the right *is* the preview; a preview inside a 30-column dock shows nothing useful |
| Selection exits? | No — the dock performs the switch and keeps running | Exiting is the popup's behaviour and the whole point is not to close |
| Closing the dock | `prefix + b` only | `Esc`/`q` closing it too — inherited from the popup, where closing is harmless; here a stray `Esc` mid-navigation would tear down the window layout |
| What `Esc`/`q` do instead | `Esc` clears the query; with an empty query both move focus to the work pane | Making them inert — a key that visibly does nothing reads as broken |

## 4. Layout

```
┌──────────┬───────────────────────────────┐
│ Sessions │                               │
│  default │  the window you are working    │
│ ⠋ dotfi… │  in — a normal tmux pane,     │
│  gogo-d… │  focused, you type here       │
│──────────│                               │
│ Agents   │                               │
│ ⠋ .conf… │                               │
└──────────┴───────────────────────────────┘
  ^ dock pane, fixed width      ^ everything else in the window
```

- Width from `@agent_switcher_dock_width`, default **30** columns. If the
  current window is narrower than twice that, the toggle refuses to open and
  says so rather than creating a dock with no room to work beside it.
- The dock renders the two sections and the search bar only. **No modal top
  bar** (the `agent-switcher` / `[?] Help` strip belongs to the popup's
  full-screen frame) and **no preview**. `?` still toggles the help list, which
  overlays the sections exactly as it does in the popup.
- The dock never appears as a row in its own list: rows are windows, and the
  dock is a pane. It is also invisible to agent detection, which matches on
  process names the switcher binary does not carry.

## 5. Mechanism

State lives in tmux options, so the toggle script, the hook and the binary all
agree without a side channel:

| Option | Scope | Holds |
|---|---|---|
| `@tmux_agent_switcher_dock_pane` | global | The dock's `pane_id`, or unset when closed |
| `@tmux_agent_switcher_dock_moving` | global | Re-entry guard while a move is in flight |
| `@tmux_agent_switcher_dock_layout` | window | The host window's `window_layout` from before the dock arrived |

**Opening** (`prefix + b`, dock not present): save the current window's
`#{window_layout}`, `split-window -bhd -l <width>` running
`tmux-agent-switcher dock`, record the new `pane_id`.

**Following.** The hooks are `session-window-changed` (the session's active
window changed — covers `prefix+n`, `select-window`, tree mode) and
`client-session-changed` (the client moved to another session). Both names
verified against tmux 3.7b; note that `after-switch-client` does **not** exist,
so `client-session-changed` is the only route for session moves.

Install them at a **reserved index** — `session-window-changed[50]` — rather
than plain `set-hook -g`. Hooks are arrays: an indexed write is idempotent
across the config reloads that re-run the plugin's `.tmux`, and it leaves any
other plugin's entry at a different index untouched. A plain write would
silently replace whatever else was there.

When a hook fires: if the dock exists and is not already in the newly active
window — save that window's layout, then

```
move-pane -b -h -d -l <width> -s <dock_pane> -t <active pane of the new window>
```

`-d` leaves the moved pane inactive, so the hook never steals focus and no
re-select is needed. On leaving a window, restore its saved layout and unset the
window option.

**Closing** — `prefix + b` again, and nothing else: kill the pane, restore the
host window's layout, unset the global. See §6 for what `q` and `Esc` do
instead.

Three hazards, each with a specific answer:

- **Hook recursion.** `move-pane` changes the active window and re-fires the
  same hooks. The `_dock_moving` flag is set before the move and cleared after;
  a hook that sees it returns immediately.
- **Layout damage.** Saving `window_layout` *before* inserting and restoring it
  after the dock leaves is the accurate mechanism tmux offers. If panes were
  created or destroyed while the dock was there the saved string no longer
  matches the pane set and `select-layout` fails — the failure is ignored and
  the window keeps tmux's own arrangement. Restoring geometry is a courtesy,
  not a guarantee worth erroring over.
- **Stale pane id.** If the recorded pane no longer exists (killed directly,
  server restarted), the toggle treats the dock as closed and opens a fresh one
  rather than failing.

## 6. Two run modes, one binary

`tmux-agent-switcher dock` joins `status-daemon` as a subcommand. It shares
every row, section, cursor and rendering type with the popup. Exactly two
things differ:

1. **It does not exit on selection.** `run_tui_loop` currently returns a
   `SwitcherAction` and the process ends. In dock mode the action is executed
   in-loop and the loop continues.
2. **It has no preview.** The dock forces its own layout — the full pane width
   is the list — rather than reusing `ViewMode`. The `v` view cycle is inert in
   the dock, since sidebar/sidebar-right/palette are all popup geometries.
3. **Nothing inside the dock closes it.** `prefix + b` is the only way out.
   In the popup, `Esc` clears the query and then closes, and `q` quits — a dock
   that inherited either would collapse the window layout on a stray keypress
   while navigating.

   The two keys keep their useful half and lose the fatal one: `Esc` still
   clears the query, and once the query is empty `Esc` and `q` both move focus
   to the work pane. "Get me out of here" still works; it just means *out of
   the sidebar* rather than *destroy the sidebar*, which is what the key
   should have meant all along in a surface you do not want to keep reopening.

Everything else — the two sections, `Tab` focus, `h`/`l` folding, search,
expansion persistence — behaves exactly as it does in the popup.

## 7. Mouse

tmux's default root binding is `MouseDown1Pane → select-pane -t = ; send -M`,
so a single click both focuses the dock and forwards the event to the
application. No double-click, and no new tmux binding required.

`handle_mouse` currently handles only scroll. It gains: map the click's `y` to
a row using the same `section_heights` and `visible_range` the renderer uses,
set focus to whichever section was clicked, move that section's cursor to the
row, and select it. A click in a section's title row or past its last row moves
focus to that section without selecting — clicking empty space should not
teleport you somewhere.

## 8. Selecting

| Row | Action |
|---|---|
| Session | `switch-client -t <session>` |
| Window | `select-window` + `select-pane` |
| Agent | `select-window` + `select-pane` on the agent's window |

Focus then lands in the work pane. The follow hook carries the dock along as a
consequence, so a sidebar selection and an ordinary `prefix+n` take the same
code path — the dock does not need to know which one moved you.

## 9. Testing

Unit-testable, and where the value is:

- Click `y` → row resolution, including the title row, the gap past the last
  row, and a scrolled section whose `visible_range` does not start at 0.
- The dock/popup mode split: a selection in dock mode must not terminate the
  loop, and must in popup mode.
- The tmux command construction: build the `move-pane`, `split-window` and
  `select-layout` argument vectors as pure functions and assert their contents,
  so the flag order and the `-d` that keeps focus put are pinned by tests
  rather than by a shell script nobody re-reads.

**Not unit-testable, needs a manual checklist:** the hook behaviour itself.
Opening in a multi-pane window and confirming the layout returns; switching
windows rapidly and watching for flicker or a doubled dock; killing the dock
pane directly and confirming the next `prefix + b` recovers; detaching and
reattaching with the dock open.

## 10. Risks

- **The follow hook is the load-bearing bet.** A `move-pane` on every window
  change is the part most likely to disappoint in practice — latency at speed,
  or layout churn in windows you merely pass through. The follow rule must
  therefore be a single policy point in the code, so falling back to
  "sidebar-initiated moves only" is a one-line change and not a rewrite.
- **One dock, one place.** With two clients attached to different windows the
  dock follows whichever moved last. Single-client is the documented
  assumption; this design does not try to beat it.

## 11. Out of scope

- A dock per window, or per client.
- Dragging the dock's edge to resize (tmux's own pane resize still works).
- Reordering or renaming from the dock beyond what the popup already does.
- Changing the popup in any way.
