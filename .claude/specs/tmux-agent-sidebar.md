# tmux agent sidebar (working name: `drover`)

Design for a tmux plugin that reproduces herdr's sidebar — a **spaces** section
(tmux sessions) and an **agents** section (running CLI agents with live status),
both clickable to focus — with agent state detected from screen content rather
than from hooks installed into the agent CLIs.

**Status: designed, not scheduled — and two findings undercut building it.**

1. **The premise may be gone.** herdr
   [#1295](https://github.com/herdrdev/herdr/issues/1295) fixed the exact stall
   this project exists to escape, shipped in **v0.8.0** (2026-08-03) — the
   version now installed. See [§1](#1-motivation--and-why-the-premise-may-no-longer-hold).
2. **Most of it already exists.**
   [Ymirke/tmux-agent-switcher](https://github.com/Ymirke/tmux-agent-switcher)
   (Rust, MIT, active) implements the hookless detection, session grouping, and
   distribution story. See [§3.1](#31-tmux-agent-switcher--closest-existing-implementation).

**Do both checks before writing any code.** If herdr 0.8.0 is smooth, stop. If
not, adopt tmux-agent-switcher and contribute the two gaps rather than starting
over.

---

## 1. Motivation — and why the premise may no longer hold

> **⚠ BLOCKING: verify before building anything.** The performance problem that
> motivates this entire design appears to have been **fixed upstream in herdr
> v0.8.0, released 2026-08-03** — the version currently installed (Cellar dated
> 2026-08-04). Re-test before spending a single day on implementation.

The trigger for leaving herdr is **performance**, not features. Investigated
2026-07-04→07 (see `[[ghostty-tip-herdr-lag]]` memory): herdr's retained-patch
path fails on every scroll frame, emitting ~30 full ~120KB frames/sec (3.6 MB/s)
where tmux writes tiny diffs. Switching brew cask `ghostty` (stable 1.3.2) →
`ghostty@tip` on 2026-07-07 fixed the *amplifier* — a slow render path in ghostty
stable on macOS 26 — but not the cause.

### Upstream status (checked 2026-08-05)

herdr is Apache-2.0, `github.com/herdrdev/herdr`.

- **[#512](https://github.com/herdrdev/herdr/issues/512)** — "Stuttering or even
  freezing when scrolling window history, herdr cpu 100%". Filed and closed
  2026-06-08, released **v0.6.9** (2026-06-10). This is the ticket referenced in
  memory, but it covers *scrollback navigation*, not nvim redraw. Its comment
  thread is where the ghostty/Tahoe angle originated.
- **[#1295](https://github.com/herdrdev/herdr/issues/1295)** — "Alt-screen TUI
  full-viewport repaints stall the child's PTY write (40–500ms/frame) in a pane;
  smooth in native terminals". **This is the actual bug.** Filed 2026-07-10 by
  `jasonrr` — three days after the investigation above ended, with an independent
  reproducer branch and timing instrumentation. Closed 2026-07-22; preview
  2026-07-29; **released in v0.8.0 on 2026-08-03**. The fix reverts a coalescing
  workaround so one input event → one redraw → one flush.
- **[#283](https://github.com/herdrdev/herdr/issues/283)** — "Reduce visible wave
  effect when scrolling pane scrollback". Closed/completed 2026-05-25.

Timeline: diagnosed 07-04→07 → own issue draft **deleted, never filed** → #1295
filed independently 07-10 → fixed → shipped in v0.8.0 on 08-03 → v0.8.0 installed
08-04.

### What to do before implementing

1. Hold `j`/`k` and scroll a large syntax-highlighted file in nvim under herdr
   0.8.0. Compare against tmux.
2. **If smooth:** the premise is gone. What remains is preference, not pain —
   a materially different decision. Do not build.
3. **If still slow:** file it with the existing profiler numbers. Track record is
   good — #512 reproduced same-day, #1295 closed in twelve days.

> **This design does not make anything faster.** It is a consequence of switching
> to tmux, not a solution to the problem that motivates switching. Switching to
> tmux and building this sidebar are separate decisions with wildly different
> costs.

> **This design does not make anything faster.** It is a consequence of switching
> to tmux, not a solution to the problem that motivates switching. Switching to
> tmux and building this sidebar are separate decisions with wildly different
> costs.

Losing herdr also breaks the nvim↔agent round trip that `herd.nvim` provided
(dropped in `d3cc9dd`, "drop sidekick.nvim now that herd.nvim covers it").
**sidekick.nvim returns as the bridge**, which materially shapes section 5.

---

## 2. Decision: build later

Estimated effort, honestly:

| Subsystem | Estimate |
|---|---|
| Detection engine (matcher, regions, poller, argv resolution) | 1–2 wk |
| Pane/space model, sidekick filter, git-root attribution | ~3 d |
| Daemon + socket protocol | ~3 d |
| ratatui client — render, mouse, keys, menus | 1–2 wk |
| tmux integration — plant, toggle, pin, reconcile, resurrect | ~1 wk |
| nvim companion + RPC round trip | ~1 wk |
| Notifications, new space / worktree | ~1 wk |
| **Total** | **4–8 weeks of evenings** |

**Plan: verify the premise first (§1), and only then consider switching.** If
herdr v0.8.0 resolved the stall, stop here — this design has no motivation left.

If the switch does go ahead: **switch to tmux, live without the sidebar, build
only what is actually missed.** Two weeks of real usage is better spec input than
any amount of up-front guessing. Expected finding: *"is anything waiting on me?"*
is missed badly; clickable rows, grouped mode, and worktree creation are barely
noticed.

Build order if it goes ahead — see [§11](#11-build-order).

---

## 3. Prior art (surveyed 2026-08-05)

> **⚠ SUPERSEDED in part.** The initial survey missed
> [Ymirke/tmux-agent-switcher](https://github.com/Ymirke/tmux-agent-switcher),
> which implements most of this design already — hookless, Rust, MIT. See
> [§3.1](#31-tmux-agent-switcher--closest-existing-implementation). Evaluate it
> before building anything.

Most existing tmux agent sidebars get state from **CLI-side hooks**, which is the
one thing ruled out.

| Project | Sidebar | Mouse | Agent state | Lang / license |
|---|---|---|---|---|
| [hiroppy/tmux-agent-sidebar](https://github.com/hiroppy/tmux-agent-sidebar) | yes | — | hooks | Rust, MIT, 434★ |
| [sandudorogan/tmux-pane-tree](https://github.com/sandudorogan/tmux-pane-tree) | yes, mirrored | right-click menus | hooks only (`install-agent-hooks.sh` patches `~/.claude/settings.json`, `~/.codex/config.toml`, `~/.cursor/hooks.json`) | Shell+Python, MIT, 48★ |
| [samleeney/tmux-agent-status](https://github.com/samleeney/tmux-agent-status) | yes | fzf only | hooks | Shell, **no license**, 256★ |
| [accessd/tmux-agent-indicator](https://github.com/accessd/tmux-agent-indicator) | no | no | hooks + process-liveness fallback | Shell, MIT, 85★ |
| [brendandebeasi/tabby](https://github.com/brendandebeasi/tabby) | yes | **full mouse** | none | Go, MIT, 72★ |

Useful references rather than fork targets: **tmux-pane-tree** for sidebar
mirroring mechanics, **tabby** for mouse handling.

### 3.1 tmux-agent-switcher — closest existing implementation

[Ymirke/tmux-agent-switcher](https://github.com/Ymirke/tmux-agent-switcher) —
Rust, MIT, 17★, created 2026-07-02, active (pushed 2026-08-01). Missed in the
first survey pass; surfaced by the user 2026-08-05.

**Implements most of this design already:**

| This spec | tmux-agent-switcher |
|---|---|
| Hookless screen + title detection | ✅ "fully passive… never wraps, shims, or launches your agents" |
| Braille spinner in OSC title → working | ✅ identical (`starts_with_braille_status`, `U+2800..U+28FF`) |
| Screen-tail regions → blocked | ✅ same approach, with idle→busy debounce |
| claude / codex / opencode | ✅ exactly those three |
| Rust single binary | ✅ **prebuilt binaries on release** — answers the §12 distribution question |
| Daemon/poller | ✅ self-starting background poller |
| Pure-function detection tests | ✅ `tests/opencode_status.rs` + inline unit tests |
| Spaces = tmux sessions | ✅ `SessionGroup`, `group_cards_by_session` |
| New space / new window | ✅ prompts for both |

**Beyond this spec:** live scaled preview of the highlighted window; **tab status
indicators** (rolled-up agent state appended to each window tab without replacing
the user's format) — ambient awareness with no sidebar at all.

**Gaps against the requirements agreed here:**

1. **Popup, not a persistent sidebar.** `display-popup -B -e` on `C-n`.
   `ViewMode::Sidebar` is a layout mode *inside* the popup. §7's always-visible
   mirrored pane with toggle is absent.
2. **No click-to-focus.** Calls `EnableMouseCapture`, but `handle_mouse` handles
   only `ScrollUp`/`ScrollDown`.
3. **Installs its own bindings** (`C-n`, `-n C-h/j/k/l`) — contrary to §7's
   ship-commands-not-bindings decision. Key is configurable via
   `@agent_switcher_key`; the vim-nav binds would collide with the commented-out
   `M-h/j/k/l` block in `tmux/tmux.conf`.
4. **Detection is hardcoded Rust match arms**, not TOML manifests — simpler for
   three agents, less extensible than §5.
5. **sidekick detached sessions untested.** `claude a1b2c3d4` sessions would
   likely appear as ordinary sessions; may need §6's 17-char filter.

**Revised recommendation: adopt, then contribute.** Install it (TPM one-liner)
and use it. If the persistent sidebar and clickable rows are genuinely missed,
contributing them upstream to an active MIT repo is far cheaper than the 4–8 week
greenfield build in §2 — and §§6, 7 and 9 of this spec become the contribution
roadmap rather than a from-scratch plan.

### How herdr actually does it

Two layers, verified against the local install:

1. **Screen/title detection (primary, no CLI-side install).** Per-agent TOML
   manifests at `~/.local/state/herdr/agent-detection/remote/*.toml` (19 agents,
   96 rules), auto-updated from a remote. Rules are
   `region` + `priority` + `contains`/`regex`/`line_regex`/`any`/`all`/`not` →
   `state`. Exposed standalone as `herdr agent explain --file <f> --agent <id>`,
   which works with no server and no hooks.
2. **Integration hooks (optional).** `herdr integration install <agent>` writes
   a CLI-side reporter that talks over a unix socket (`HERDR_SOCKET_PATH` +
   `HERDR_PANE_ID`, method `pane.report_agent`).

For Claude specifically the hook is wired to **SessionStart only** and reports
session *identity*; working/idle/blocked is entirely screen-detected. That is
the model this design copies.

---

## 4. Architecture

One Rust binary, three roles. Rust chosen for single-binary distribution,
ratatui's mouse/render quality, and direct correspondence with herdr's own
implementation.

```
                    ┌─────────────────────────────┐
                    │  drover daemon              │  one per tmux server
   tmux ──poll──▶   │  • list-panes -a (1 call)   │
                    │  • capture-pane (agents only)│
                    │  • classify via manifests   │
                    │  • diff → notifications     │
                    └──────────┬──────────────────┘
                               │ unix socket, newline-delimited JSON
                    ┌──────────┴──────────┬──────────────┐
                    ▼                     ▼              ▼
            ┌──────────────┐     ┌──────────────┐   ┌─────────┐
            │ drover ui    │     │ drover ui    │   │ drover  │
            │ (win 1 pane) │     │ (win 2 pane) │   │ <verb>  │
            └──────┬───────┘     └──────┬───────┘   └────┬────┘
                   └───── tmux commands (switch-client, select-pane, …) ─────┘
```

**The daemon is a pure observer; it never mutates tmux.** Clients are the only
actors. This keeps the protocol one-directional (snapshot push) and means a
wedged daemon degrades to a stale display rather than broken navigation.

- **Lifecycle** — spawned on demand by the `.tmux` entrypoint and by `drover ui`
  if the socket is absent (self-healing). Single-instance via socket bind. Exits
  when the tmux server disappears.
- **Tick (~500ms)** — one `list-panes -a` → diff pane set → `capture-pane -p`
  for agent panes only → classify → build snapshot → diff for notifications →
  broadcast.
- **Client-local state** — selection cursor, scroll offset, collapsed sections
  live in each sidebar pane, so two windows can have cursors in different places.

---

## 5. Detection engine

The differentiator; no prior art to copy.

### Agent identification

`pane_current_command` is insufficient — Claude Code frequently reports as
`node`. Three tiers, cheapest first:

1. `pane_current_command` in the known set (`claude`, `codex`, `opencode`, …).
2. Command in the ambiguous set (`node`, `bun`, `deno`, `python`, `uv`) → resolve
   argv. One `ps -ax -o pid=,ppid=,args=` per tick for the whole server, build
   the pid tree once, walk down from each `pane_pid`. Cached on
   `(pane_pid, pane_current_command)`; steady state costs nothing.
3. Last resort: identify from screen content via the same manifests. Low
   priority — tiers 1–2 cover essentially everything.

**sidekick-spawned agents skip all of this** — the tool name is in the session
name (see §6).

### Manifest schema

herdr's grammar, our own rule content. Authored by observation rather than
copied. (herdr is Apache-2.0, so reuse would likely be permissible with
attribution — the manifest files themselves carry no license header, and they are
fetched to `~/.local/state` at runtime rather than shipped. Authoring our own
sidesteps the question entirely and avoids silent rot once herdr's update channel
is no longer present.)

```toml
id = "claude"
aliases = ["claude-code"]

[[rules]]
id = "title_working"
state = "working"
priority = 1100
region = "osc_title"
regex = ['^[\x{2800}-\x{28FF}] ']   # braille spinner
```

Match keys: `contains` / `regex` / `line_regex`, composed with `any` / `all` /
`not`. Highest-priority match wins; no match on a known agent falls back to
`idle`. Start with claude, codex, opencode (~22 rules).

### Regions

| region | tmux source |
|---|---|
| `osc_title` | `#{pane_title}` |
| `whole_recent` | `capture-pane -p -S -50` |
| `bottom_non_empty_lines(N)` | last N non-empty lines of the capture |
| `after_last_horizontal_rule` | scan capture for last box-rule run |
| `prompt_box_body` | text inside the last box-drawing frame |

**Dropped:** `osc_progress` (OSC 9;4) and `after_last_prompt_marker` (OSC 133) —
tmux surfaces `pane_title` but not these. 5 of herdr's 96 rules use them;
accepted fidelity loss.

Detached tmux sessions are fine: the server processes pane output continuously
regardless of client attachment, so `capture-pane` and `pane_title` both work.
sidekick relies on this too (`capture-pane -p -S -<dump> -E - -e` for scrollback).

### States

`working` / `blocked` / `idle` / `done` / `unknown`.

`done` is **idle-after-unseen-work**, cleared when that pane's window becomes
active in an attached client. Without per-pane "seen" tracking every finished
agent shows a permanent checkmark, which is noise.

### Cost control

Capture only agent panes, only the bottom 50 lines. Six agents at 500ms is ~12
`capture-pane` calls/sec. The tick backs off to 2s for panes idle >30s.

---

## 6. Pane and space model

Two agent populations with mirrored difficulty:

| | sidekick-spawned | hand-started |
|---|---|---|
| Lives in | detached session `claude_3 a1b2c3d4` | normal pane in a workspace session |
| Identify tool | free — it's the session name | hard — `pane_current_command` is often `node` |
| Focus | hard — nvim RPC round trip | trivial — `select-pane -t <pane_id>` |
| Attribute to space | cwd hash → match | trivial — already in that session |

```rust
struct AgentPane {
    pane_id, cwd, tool, state, space: SpaceRef,
    origin: Origin,
}
enum Origin {
    Native,
    Sidekick { agent_session: String, nvim: Option<NvimRef> },
}
```

Focus dispatches on `origin` — one match, three arms.

### sidekick session naming

From `lua/sidekick/cli/session/tmux.lua`:

```lua
M.sid = ("%s %s"):format(tool, vim.fn.sha256(cwd):sub(1, 16 - #tool))
--   → "claude a1b2c3d4e5"   (always exactly 17 chars)
```

Creation modes:

```lua
create = "terminal"  -- tmux new -A -s "<sid>"        (default; shown in an nvim float)
create = "window"    -- tmux new-window -dP -c <cwd>
create = "split"     -- tmux split-window -dP -c <cwd>
```

Prior config (`d3cc9dd^:nvim/lua/plugins/llm-config.lua`) set `mux.backend =
'tmux'` with no `create` → **`terminal` mode**, agents in nvim floats. The
numbered-clone workaround (`^(.-)_(%d+)$`) is where the `claude_2` / `claude_3`
labels come from, and clone names flow into `sid`.

**Spaces filter:** session name matching `^\S+ [0-9a-f]+$` with `len == 17` is a
reliable discriminator for agent sessions. Without it the spaces list fills with
hash-named junk.

**Attribution:** match **git root** of the agent's cwd against each space's git
root (handles worktrees), falling back to path prefix, then `unassigned`.

**Orphans are real.** sidekick uses `tmux new -A`, so its sessions persist by
design. Closing a workspace leaves a running agent session with no nvim attached
and no matching space. These are resumable work, not garbage — shown in an
`unassigned` group at the bottom of the agents section with `kill` in the context
menu. Hiding them would lose work; listing them normally would lie about where
they live.

---

## 7. Sidebar UI

```
┌────────────────────────┐
│ spaces                 │  ← section header, dim
│                        │
│ · momeppkt-home        │  ← current session, inverted row
│                        │
│ ○ dotfiles-config      │  ← green dot = agent working
│   develop              │  ← branch, dim
│                        │
│ · gogoboard-7          │
│   feature/cpu-profiling│
├────────────────────────┤
│ agents        grouped  │
│                        │
│ ○ dotfiles… · claude_3 │
│ ○ gogoboar… · claude   │
└────────────────────────┘
```

- Fixed width (default 30, configurable). Spaces sized to content up to a cap;
  agents take the remainder; both scroll independently.
- Hard truncation with `…`, never wrapping — keeps rows on a fixed rhythm.
- Defaults bake in personal preferences (palette from herdr `config.toml`, width,
  section split) so `tmux.conf` carries only bindings.

### Input

**Two paths, deliberately separate:**

- **tmux-level verbs** work without focusing the sidebar — `drover toggle`,
  `focus-agent N`, `prev-agent`, `next-agent`, `next-pane`, `prev-pane`.
- **In-sidebar keys** apply only when the sidebar pane holds focus — `j/k` or
  `↑/↓`, `Enter`, `g/G`, right-click for the context menu. These are ratatui's
  own key handling, not tmux bindings.

Click resolution: space row → `switch-client -t <session>`; agent row → dispatch
on `origin` (§6, §8).

### The plugin ships commands, not bindings

`drover` registers **zero** `bind-key` calls. Suggested bindings are documented
in the README only:

```tmux
bind-key b    run -b "drover toggle"
bind-key S-1  run -b "drover focus-agent 1"
bind-key Up   run -b "drover prev-agent"
bind-key Down run -b "drover next-agent"

# sidebar-aware pane cycling, replacing bind-key h/l select-pane -t :.- / :.+
bind-key h run -b "drover prev-pane"
bind-key l run -b "drover next-pane"
```

`prefix + b` (`C-a b`) is free — not in the current config, not a tmux default,
and tmux-toggle-popup binds nothing on its own.

**Line drawn: mechanism ships, policy does not.**

- **Plugin does** — start the daemon, set `-ga` hooks, plant initial sidebars.
  Without these it does not function.
- **User does** — every keybinding, and the `@resurrect-processes` append (§9).
  That one mutates another plugin's option, so it is documented, not applied.

Positional pane cycling (`select-pane -t :.-` / `:.+`) walks into the sidebar
every lap. The `drover next-pane` / `prev-pane` wrappers skip `@drover`-marked
panes — opt-in, not a rewrite of existing binds.

---

## 8. nvim integration

sidekick already broadcasts what is needed. From `lua/sidekick/util.lua`:

```lua
function M.emit(event, data)
  vim.api.nvim_exec_autocmds("User", { pattern = event, modeline = false, data = data })
end
--   "SidekickCliAttach" / "SidekickCliDetach", data = { id = session.id }
```

So a small **`drover.nvim` companion** subscribes rather than doing pid
archaeology across three layers:

```lua
vim.api.nvim_create_autocmd("User", {
  pattern = { "SidekickCliAttach", "SidekickCliDetach" },
  callback = function(ev) report(ev.match, ev.data.id) end,
})
```

On `VimEnter` it registers `{ pane_id = $TMUX_PANE, servername = v:servername,
pid }` with the daemon. The daemon then holds an exact map: agent session →
owning nvim → hosting tmux pane → RPC address.

**Click path, two hops:**

```
click "claude_3" row
   → tmux switch-client -t <space> ; select-pane -t <nvim pane>
   → nvim --server <servername> --remote-expr
         'v:lua.require("drover").focus("claude_3")'
   → drover.nvim calls sidekick State.attach → float opens
```

**This is a hook, but on the accepted side.** The constraint was no hooks in the
*CLI tools*; detection stays hookless and works for anything. The companion only
enriches focus and never participates in classification.

**Degradation:** without `drover.nvim`, or for hand-started agents, the daemon
falls back to `tmux list-clients -F "#{session_id}:#{client_pid}"` plus a
parent-chain walk, and clicking focuses the hosting pane without raising the
float. Detection is unaffected either way.

---

## 9. tmux integration

Target: tmux 3.7b. `set -g mouse on` already set.

### Self-marking (verified)

```
$ tmux set -p @drover 1
$ tmux list-panes -a -F '#{pane_id} mark=[#{@drover}]'
%0 mark=[1]
```

Pane-scoped user options work and are readable in format strings, so the daemon's
existing single `list-panes -a` filters its own panes for free. Using
`pane_title` for this would collide with detection, which reads `pane_title` as
the `osc_title` region.

### Planting — hooks for latency, daemon tick for correctness

```tmux
set-hook -ga window-linked         'run -b "drover plant -t #{window_id}"'
set-hook -ga session-created       'run -b "drover plant-session -t #{session_id}"'
set-hook -ga window-layout-changed 'run -b "drover pin-width"'
```

`-ga` **appends** — clobbering global hooks would silently break other plugins.
The daemon already enumerates every pane each tick, so a missed hook or a crashed
`drover ui` self-corrects within one tick. No separate watchdog.

`window-layout-changed` → `pin-width` prevents `select-layout even-horizontal`
from giving the sidebar an equal share.

### Toggle

Global, not per-session (`the` sidebar, not one per session). `drover toggle`
kills all marked panes and records `@drover_visible 0` in a global user option,
or replants from it. Killing rather than resizing — tmux will not resize a pane
to zero width, and client state is cheap to rebuild.

### tmux-resurrect / continuum

Current config: `@continuum-restore 'on'`, `@continuum-save-interval '15'`.

resurrect saves pane commands but only restores processes listed in
`@resurrect-processes`, so by default sidebar panes return as blank shells
occupying the sidebar slot. **Opt in rather than fight it:**

```tmux
set -ga @resurrect-processes ' "~drover ui"'
```

Rejected alternative: kill pre-save / replant post-save via resurrect hooks —
continuum would run that every 15 minutes, causing visible flicker and lost
selection on a timer. `drover reconcile` on post-restore handles duplicates.

---

## 10. Notifications, new space, errors, testing

### Notifications

The daemon holds previous state, so a transition is a diff on the snapshot it
already builds. Fire only on:

- `working → blocked` — needs input
- `working → idle` — finished

Suppressed when the agent's pane is visible in an attached client, reusing the
same "seen" tracking that drives the `done` badge. Delivery via
`terminal-notifier` if present, falling back to `tmux display-message`. The
notification carries its target so a click routes through `drover focus-agent`.

### New space

`drover new-space` prompts for a directory, then `tmux new-session -d -s <name>
-c <path>`. With `--worktree`, runs `git worktree add` on a new branch first.
Deliberately thin: shells out to `git`, holds no worktree state, surfaces git
errors verbatim.

### Error handling

**The sidebar is an observer; no failure should break a tmux session.** Every
mode degrades to less information, never broken navigation.

| Failure | Behavior |
|---|---|
| Daemon not running | `drover ui` spawns it; if that fails, render last snapshot with a dim `stale` marker |
| Daemon crashes | Clients keep last snapshot, retry with backoff. Navigation still works — clients issue tmux commands directly |
| `drover ui` pane dies | Daemon replants on next tick |
| `capture-pane` fails | That pane goes `unknown`; tick never aborts |
| Manifest parse error | Log once, skip that agent's rules, keep the rest |
| nvim RPC unreachable | Focus the hosting pane without raising the float |
| tmux server gone | Daemon exits cleanly |

### Testing

Splits along the same boundaries as the architecture — the point of drawing them
where they are.

- **Manifest matcher — pure function, the bulk of the tests.**
  `(regions, rules) → state`, against fixture files of captured pane text per
  agent per state. No tmux, no processes. Correctness lives here and stays
  testable because the input is just text.
- **Pane-model builder — pure function.** Recorded `list-panes -a` output →
  spaces tree + agents list. Covers the 17-char sidekick filter, git-root
  attribution, orphan grouping, argv resolution.
- **tmux integration — real throwaway server** (`tmux -L drovertest -f /dev/null`).
  Planting, toggle, width pinning, reconcile. Isolated socket, no risk to the
  live session.
- **TUI render — snapshot tests.** Fixed snapshot + terminal size → expected buffer.
- **Not unit-tested:** daemon tick loop, nvim RPC round trip. Thin glue over
  tested pieces; mocking them would test the mocks.

**Wanted early:** `drover explain <pane-id>`, mirroring `herdr agent explain` —
prints matched rule, region, and evidence. Debugs misclassification without
instrumentation and doubles as the fixture-capture tool for matcher tests.

---

## 11. Build order

**v0 — answers "is anything waiting on me?" (~1–2 wk, ~20% of total)**
Daemon + detection engine + manifest matcher + pane/space model +
`drover explain` + a `prefix + b` popup list. No mirrored panes, no resurrect
interaction, no pane-cycling wrapper, no nvim RPC.

**v1 — the sidebar proper**
ratatui client, mirrored pane planting, toggle, width pinning, mouse
click-to-focus, in-sidebar keys.

**v2 — the expensive tail**
`drover.nvim` companion and RPC round trip, notifications, context menus,
new space / worktree, grouped mode.

Build v0 first, then decide from real usage whether v1 and v2 earn their cost.

---

## 12. Open questions

- **Name.** `drover` is a placeholder chosen to keep the herding metaphor without
  colliding with herdr. Cosmetic; settle before implementation.
- **Distribution.** TPM installs by `git clone`, and cargo builds are slow enough
  that build-on-install is unpleasant. Likely: shipped release binaries plus a
  download shim in the `.tmux` entrypoint. Undecided.
- **Manifest updates.** Own rules mean own maintenance as agent TUIs change.
  No update channel designed; `drover explain` plus fixture tests is the
  mitigation, but drift is a real ongoing cost.
- **Missing prior investigation.** The `[[ghostty-tip-herdr-lag]]` memory points
  to `~/.config/.claude/notes/herdr-nvim-key-repeat-lag.md` for profiler numbers,
  but `.claude/notes/` is empty — that write-up is gone.
