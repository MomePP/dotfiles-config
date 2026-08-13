# Agent-dock status hooks

Let the agent report its own state instead of the dock guessing at it.

## Why

The status daemon infers state passively: it walks the process tree, reads the
OSC title, and captures the last 25 lines of every agent pane, three times a
second, for the life of the tmux server. Two costs follow from that, and both
were paid in full on 2026-08-13.

**It burns battery.** Roughly 90% of the daemon's CPU time is system time — the
cost is 3–5 `fork`/`exec` per poll and the wakeups they imply, not arithmetic.
See [[tmux-agent-dock]] for the measured numbers.

**It is guessing.** Claude Code changed its title spinner from braille to the
quarter circles (`◐ ◑ ◒ ◓`) and every working Claude pane silently read as Idle,
because the title is the only thing in the Claude path that votes Working. A
cosmetic change upstream turned the dock's central feature off, and nothing
failed loudly.

An agent that says "I started", "I am waiting on you", "I am done" removes both
problems at once. The state becomes exact, and the expensive half of the poll
becomes unnecessary.

## What is being built

1. `tmux-agent-dock report` — a CLI subcommand that writes one pane's agent
   status, using the same code path the daemon writes through.
2. `agent-dock-status` — a Claude Code plugin, shipped from the dock's own repo,
   whose hooks call that subcommand.
3. Daemon changes — hook-reported state is authoritative; per-pane inference is
   skipped for panes that report; the loop degenerates into a watchdog when
   every agent pane reports.

Nothing about the dock UI changes. It reads the same pane options it reads now.

## The contract

State lives where it already lives: in tmux pane options, which die with the
pane and so need no cleanup.

| Option | Owner | Meaning |
| --- | --- | --- |
| `@tmux_agent_dock_agent` | both | which agent (`claude`, `codex`, `opencode`) |
| `@tmux_agent_dock_state` | both | `working` / `blocked` / `idle` |
| `@tmux_agent_dock_run_started_at` | both | unix seconds the current run began |
| `@tmux_agent_dock_seen` | both | whether the finish was witnessed |
| `@tmux_agent_dock_hooked` | **new**, report | `1` once this pane has ever reported |
| `@tmux_agent_dock_hook_seq` | **new**, report | monotonic stamp of the last report |

`@tmux_agent_dock_hooked` is **sticky and has no TTL**. A TTL is the obvious
design and it is wrong: an idle agent emits no events for hours, so any
freshness window short enough to catch a broken hook is also short enough to
drop a healthy idle pane back into inference. The marker is cleared when the
agent is *gone* — by `SessionEnd`, or by the watchdog finding no agent process
under the pane — which is the only event that actually invalidates it.

`@tmux_agent_dock_hook_seq` is a nanosecond stamp. A report whose seq is not
greater than the stored one is dropped, so an async or delayed hook cannot
clobber a newer state with an older one. This is the same guard the herdr
OpenCode plugin uses (`opencode/plugins/herdr-agent-state.js`), and it is needed
for the same reason: hook delivery is not ordered.

### `tmux-agent-dock report`

```
tmux-agent-dock report --state working|blocked|idle \
                       --agent claude \
                       [--pane %23] \
                       [--exited]
```

- `--pane` defaults to `$TMUX_PANE`, which Claude Code inherits and which is
  already the pane id the dock keys on — including inside a sidekick.nvim
  embedded session, where `$TMUX_PANE` is the inner pane, exactly the one the
  dock tracks.
- Exits 0 and writes nothing when `$TMUX_PANE` is unset or tmux is not running.
  A hook must never fail a turn.
- `--exited` clears the pane's agent options, for `SessionEnd`.
- Reuses `stabilize_agent_status_at` and `watched` rather than reimplementing
  them, so the run timer and the unread dot keep their existing meaning. The
  visibility test the dot depends on is one `list-panes -a -f` at report time;
  the reporter can answer it as well as the daemon can.

Writes go through the existing chained `set-option` so a reader can never catch
a half-applied pair.

### Event mapping

| Claude Code event | Report | Why this one |
| --- | --- | --- |
| `SessionStart` | `idle`, sets `hooked` | Registers the pane. Fires on `startup`, `resume`, `clear`, `compact`, `fork` |
| `UserPromptSubmit` | `working` | Once per turn, at the moment work begins |
| `PermissionRequest` | `blocked` | Fires the instant Claude asks. `Notification`'s `permission_prompt` waits ~6s for you to stop typing — too slow for a dot that means "it needs you" |
| `PostToolUse` | `working` | Clears `blocked` after a permission is answered |
| `Stop` | `idle` | The turn ended. This is the edge that raises the unread dot |
| `StopFailure` | `idle` | A turn that ended badly still ended |
| `SessionEnd` | `--exited` | Clean exit; clears `hooked` so a later agent in the same pane is inferred afresh |

Every hook is `"async": true` so no report can delay a turn, and each carries a
short `timeout`. Subagent events are ignored: the herdr integrations drop
anything carrying `agent_id`, and `SubagentStop` in particular must never revive
an idle pane — Claude's recap can emit it after the main turn has stopped.

`PreToolUse` is deliberately unused. `UserPromptSubmit` → `working` and `Stop` →
`idle` already bracket the turn; a report per tool call is dozens of execs for a
state that did not change.

### Packaging

`.claude-plugin/plugin.json` and `marketplace.json` ship in the dock repo, so:

```
claude plugin marketplace add MomePP/tmux-agent-dock
claude plugin install agent-dock-status
```

The hook command resolves the binary through `$TMUX_PLUGIN_MANAGER_PATH`,
falling back to `PATH`, so a TPM checkout works without further configuration.

## Daemon changes

**Hooked panes are never inferred.** No `capture-pane`, no title parsing, no
debounce. The daemon reads their state as fact. This is where the fragility goes
away — a spinner glyph the dock has never heard of stops mattering.

**Un-hooked panes behave exactly as they do today.** A codex or opencode pane,
or a Claude that predates the plugin, still gets inference at today's cadence.
This is what keeps the change additive rather than a cutover.

**The cadence follows from the above rather than being a new rule.** The
existing `Pace` already runs fast only while something is changing; with no
un-hooked agent pane to inspect there is nothing to change, so the loop settles
onto the dormant 5s tier and stays there — through an agent's entire run.

What the 5s watchdog still does, and why it cannot be removed:

| Work | Why it must survive |
| --- | --- |
| `list-panes -a` | Notices an un-hooked agent arriving |
| `ps -A` (liveness) | A killed agent fires no `Stop` and no `SessionEnd`. Without this its pane reads Working forever |
| `embedded_session_hosts` | Keeps `@tmux_agent_dock_embedded` fresh, which is the only thing that folds a sidekick session after its float closes. Hooks cannot supply topology |
| `Tick::run_if_due` | Continuum saves have no other heartbeat since the status line was dropped |

## Failure modes

| If | Then |
| --- | --- |
| The hook never fires (not installed) | The pane is not `hooked`; inference handles it as today. No regression |
| The agent is killed | Liveness clears it within 5s. This is the reason the watchdog exists |
| One hook fails (timeout, missing binary) | That transition is lost and the state is wrong until the next report. A missed `Stop` is corrected by the next `SessionStart` or by liveness; a missed `UserPromptSubmit` self-corrects at `Stop` |
| Reports arrive out of order | The seq guard drops the older one |
| tmux is not running | `report` exits 0 silently |

The uncorrectable case is a hook that fires *sometimes*: a pane stuck at a stale
state while its process is alive. This is accepted, not designed around —
detecting it needs the inference this whole design exists to switch off.

## Testing

Unit: the seq guard drops stale reports; `--exited` clears every option; a
missing `$TMUX_PANE` is a silent no-op; hooked panes are excluded from
inference. All under `cfg(test)` with tmux writes suppressed, per the existing
convention — a plain `cargo test` must never touch the developer's live server.

Integration, against a throwaway server: report `working`, assert the option;
report `idle`, assert the unread dot rises when the pane is not visible and does
not when it is; kill the agent process and assert the watchdog clears it within
5s. Note `tmux -L` is a second socket, not a second config — see the trap
recorded in [[tmux-agent-dock]] before writing any of these.

## Non-goals

- Hooks for codex, opencode and the rest. The daemon keeps inferring those. One
  agent proves the contract first.
- Any integration with herdr's socket protocol. Its Claude hook reports only a
  session id, only when `HERDR_ENV=1`, and coupling the dock's correctness to
  another tool's wire format buys nothing here.
- Changing what the dock displays.
