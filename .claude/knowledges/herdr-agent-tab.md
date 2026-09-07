# herdr-agent-tab

## What it is

A herdr plugin: `Ctrl-a n` opens a coding agent in a new tab of the *current*
space, on the checkout or a fresh worktree. It exists because herdr and every
worktree plugin surveyed (`herdr-plus`, `mkdir700/herdr-plugin-worktree`,
`tdi/herdr-worktree-*`) model a worktree as a new *space* — this workflow
wants space = project, tab = tool or agent.

Repo `~/Developer/herdr-plugins/herdr-agent-tab`, published `MomePP/herdr-agent-tab`
(MIT, v0.1.0). Linked locally with `herdr plugin link "$PWD"` for development;
`herdr plugin install MomePP/herdr-agent-tab` to install from the release.
Key table: `.claude/knowledges/herdr-keymap.md` (`n` = new agent tab here) —
this file does not repeat it.

## How it works

The `new` action (bound to `Ctrl-a n`) only opens the popup pane — a popup is
the only plugin entrypoint that gets a TTY. `picker` runs inside that popup
and drives the whole flow:

```
new (headless action) ──► herdr plugin pane open --entrypoint picker
picker (popup, huh forms):
  1. agent    : herdr's kind list ∩ executables on PATH
  2. where    : local · <current branch>  |  worktree · new branch
  3. branch   : (worktree only) input, prefilled with the git-flow prefix
       └─ worktree? git worktree add <root>/.claude/worktrees/<slug> -b <branch> <base>
       └─ herdr tab create --workspace <id> --cwd <dir> --label <label> --focus
       └─ herdr agent start <name> --kind <kind> --pane <root_pane.pane_id>
```

Progress lines print to the popup at each stage (worktree creation, tab
opening, agent starting) so a slow step doesn't look hung.

Package layout: `internal/run` (the only place processes start — a `Runner`
interface with `Exec` for real processes and a recording `Fake` for tests /
`--dry-run`), `internal/slug` (branch → slug / tab label / agent name),
`internal/gitx` (repo root, branch, git-flow config, worktree add, exclude),
`internal/herdr` (wraps `$HERDR_BIN_PATH`, parses JSON results), `internal/app`
(`Execute` — the flow above, wired to `gitx`/`herdr`/`slug`), `internal/picker`
(huh forms), `cmd/agent-tab` (subcommand dispatch: `new`, `picker`).

## Conventions

- Worktrees land at `<repo>/.claude/worktrees/<slug>` — Claude Code's native
  `EnterWorktree` location, which the user's repos already gitignore.
  Superpowers' `.worktrees/` is only its fallback for when no native
  worktree tool exists; this plugin follows Claude Code's convention so both
  tools share one directory. `Repo.WorktreeDir` joins under `Root`, so a
  worktree created from inside another linked worktree still lands under the
  main checkout's `.claude/worktrees/`, not nested inside the worktree.
- Ignored via `.git/info/exclude`, never a tracked `.gitignore` — the plugin
  must not create diffs in the user's repositories.
- Branch prefix from `gitflow.prefix.feature`; base from `gitflow.branch.develop`,
  else the current branch. `gitflow.branch.<branch>.base` is recorded after
  creating a new branch, when git-flow is configured — mirrors what
  `git flow feature start` itself stores.
- Slug = branch lower-cased, every `/` → `-`, then anything outside
  `[a-z0-9_-]` → `-`, runs collapsed, ends trimmed.
- Agent name = `<kind>-<slug>` (or just `<kind>` for local/no-slug), capped at
  32 chars without a trailing `-`, and given a `-2`/`-3`/… suffix if that name
  is already live (herdr requires `[a-z][a-z0-9_-]{0,31}`, unique).
- Agent kinds are parsed from `herdr agent start --help`'s
  `[possible values: …]` line, intersected with `PATH` — never hard-coded, so
  a new herdr release needs no plugin release to be picked up. The last
  chosen kind is remembered in `$HERDR_PLUGIN_STATE_DIR/last-agent` and
  preselected next time.

## Gotchas

Each of these cost real debugging time; the reason is worth keeping, not just
the rule.

- **`HERDR_PLUGIN_CONTEXT_JSON` is a flat object.** It carries
  `focused_pane_cwd`, `workspace_cwd`, `workspace_id`, `tab_id`, `worktree`,
  etc. at the top level — there is no `pane` object and no `cwd` key (an
  earlier draft of this plugin assumed both, from confusing it with a `pane
  current` reply, which *does* nest cwd under `"pane"`). Looking for `cwd`
  silently finds nothing, so every popup invocation fell back to `herdr pane
  current` even though the env var already had the answer.
  `herdr.ParseContext` checks `pane` first (so a workspace-level cwd never
  shadows the pane's), then falls back through the flat keys in order of
  specificity: `focused_pane_cwd`, `foreground_cwd`, `cwd`, `workspace_cwd`.
- **A popup process gets no `HERDR_PANE_ID`** — a popup is a session
  resource, not a pane — which is exactly why context has to come from
  `HERDR_PLUGIN_CONTEXT_JSON` or `herdr pane current` rather than a pane env
  var.
- **`git check-ignore` needs the trailing slash** (`.claude/worktrees/`) to
  match a directory-only pattern against a path that doesn't exist on disk
  yet — without it, git can't tell a nonexistent path would be a directory
  and the match silently fails. It also **refuses an absolute path** when run
  from inside a linked worktree (check-ignore rejects any path outside the
  working tree rooted at cwd), so `IsExcluded` always runs with
  `cwd = Repo.Root` and the relative pattern, never an absolute path built
  from a worktree's cwd.
- **`Root` is not always `filepath.Dir(--git-common-dir)`.** That holds for
  the main checkout and for a linked worktree, but not for a submodule or a
  `--separate-git-dir` clone, where the git dir lives elsewhere entirely.
  `gitx.Open` compares `--git-dir` with `--git-common-dir`: equal means the
  simple derivation is wrong, so it re-resolves with `--show-toplevel`;
  different (a linked worktree) means `Dir(common)` is already correct.
- **A branch with no ASCII alphanumerics slugs to `""`.** A Thai (or emoji-only,
  etc.) branch name would otherwise turn `<repo>/.claude/worktrees` itself
  into a worktree directory. Guarded in two independent places: the picker's
  `validBranch` rejects a branch with no alnum before the form even submits,
  and `app.Execute` re-checks `slug.Slug(branch) == ""` and refuses with an
  explicit error — so a bug in one guard doesn't silently corrupt the
  worktrees directory.
- **huh validates a field on blur, and a form refuses backward navigation
  while the group has an error.** `group.go`'s `prevField()` blurs the field
  (running `Validate`) before honoring Shift-Tab, and `form.go`'s
  `prevGroupMsg` handler bails out early if that leaves any error on the
  group — so a naive "branch is required" validator traps the user in the
  Branch field with no way back to change Agent or Where. Fixed by making the
  field's own `Validate` accept "nothing typed yet" (empty, or still equal to
  the prefilled prefix) and enforcing "something was actually typed" in
  `picker.Run` itself, after the form returns, looping with a note shown on
  the field until it's satisfied or the user cancels.
- **huh's default keymap binds Quit to `ctrl+c` only** — Esc must be added
  explicitly (`key.NewBinding(key.WithKeys("ctrl+c", "esc"), ...)`), and on a
  bare `huh.NewConfirm()...Run()` a keymap set on the field alone does
  nothing, because `Field.Run()` builds its own wrapping form with huh's
  default keymap. `picker.Confirm` therefore builds the form explicitly so
  the Esc-aware keymap applies.
- **`ThemeCharm` puts a left border and padding on every field**
  (`Focused.Base` / `Blurred.Base`). Cleared to a bare `lipgloss.NewStyle()`
  on both so the popup's fields sit flush with herdr's own popup chrome
  instead of double-indenting. Landed together with sizing the manifest's
  popup pane to the form's actual content: `width = 48`, `height = 9`.
- **`herdr agent start` has a 30s default timeout** — this is why the flow
  prints a progress line at each stage (worktree, tab, agent) rather than
  going quiet until everything finishes.
- **Plugins only start when the herdr server restores a session.** After
  installing or updating a plugin, detach and run `herdr server stop`, then
  reopen with `herdr` — reopening a terminal on top of the same server is not
  enough. `herdr update` likewise refuses to run from inside a session.

## Errors

Every failure leaves nothing half-done and is shown inside the popup:

| Failure | Behaviour |
|---|---|
| not a git repo | the "where" step is skipped; local tab opens at the cwd |
| branch already exists | `picker.Confirm` offers "open a worktree on the existing branch" (`git worktree add <dir> <branch>`, no `-b`) or cancel — `app.Execute` returns `ErrBranchExists` unless `Request.UseExisting` is set |
| worktree dir exists | refuse with `DirExistsError{Dir}`, showing the path |
| `git worktree add` fails | git's stderr surfaces; no tab is created |
| `tab create` fails | the error is shown; the worktree (if any) stays — it's valid state — and the message says so |
| `agent start` times out or fails | the tab stays open at a shell; `AgentStartError` reports the agent did not start |

## Testing

- `internal/gitx`, `internal/slug`, `internal/app`: real git run against temp
  repositories in `t.TempDir()` — root/branch detection, git-flow prefix/base,
  exclude append, worktree add, existing-branch and existing-dir refusal.
- `internal/herdr`: `HERDR_BIN_PATH` pointed at a recording `run.Fake` that
  replays canned JSON (`tab create` → `root_pane.pane_id`, `agent start` →
  ok); tests assert the exact argv sequence for local and worktree.
- `agent-tab new --dry-run --agent claude --where worktree --branch feature/x`
  prints the three commands and is golden-tested. The golden output is
  regenerated from real output whenever the call sequence changes (extra
  `git rev-parse` calls, new progress lines, etc.) — the argv *content* is
  the contract, not the exact line count.
- Manual: live-tested end to end in `badminton-platform` — worktree mode,
  existing-branch confirm, Esc to cancel, Shift-Tab back through the form.
  All passed; the plugin was then published.

## Dotfiles side

`Ctrl-a n` → `momepp.agent-tab.new`, bound in `herdr/config.toml` under
`[[keys.command]]` (`type = "plugin_action"`). `herd.nvim` carries
`enabled = false` — agents launch from herdr, not nvim. `sidekick.nvim` is
kept but disabled. `herdr-plus` was tried first and dropped: its picker
builds a whole new space per project, which is exactly the space-per-worktree
model this plugin exists to avoid.

## Follow-ups not built

A `remove` action (drop the worktree, close the tab); issue/PR import into a
worktree; Windows support.
