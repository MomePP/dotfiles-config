# herdr-agent-tab — design

A herdr plugin that opens a coding agent in a **new tab of the current space**,
on either the current checkout or a fresh git worktree. It exists because herdr
(and every worktree plugin surveyed on 2026-09-03) models a worktree as a new
*space*; this workflow wants **space = project, tab = tool or agent**.

## Goals

- `Ctrl-a n` in any space: pick an agent, pick "local branch" or "new
  worktree", optionally name the branch, and land in a focused tab with the
  agent already running there.
- Worktrees live in `<repo>/.worktrees/<slug>` — the same convention as
  superpowers' `using-git-worktrees`, so both tools share one directory.
- Zero per-machine config: agents are discovered from `PATH`, branch prefix
  and base from the repo's git-flow config when present.
- Personal preferences are the plugin defaults (owner-maintained plugin; keep
  the dotfiles side to one keybinding).

## Non-goals (v1)

- Removing worktrees or closing agent tabs (`remove` is the first follow-up).
- Importing GitHub issues / PRs / remote branches into worktrees.
- Windows.
- Anything for non-git directories beyond offering "local" only.

## Repository

`~/Developer/herdr-plugins/herdr-agent-tab`, published as `MomePP/herdr-agent-tab`.
Go 1.27, MIT. Linked with `herdr plugin link` during development; installed
with `herdr plugin install MomePP/herdr-agent-tab` afterwards.

```
herdr-plugin.toml
go.mod
cmd/agent-tab/main.go        one binary; subcommands `new` and `picker`
internal/herdr/              wrapper over $HERDR_BIN_PATH; parses JSON results
internal/gitx/               repo root, branch, git-flow config, worktree add, exclude
internal/picker/             charmbracelet/huh forms
internal/slug/               branch → slug / tab label / agent name
```

### Manifest

```toml
id = "momepp.agent-tab"
name = "Agent Tab"
version = "0.1.0"
min_herdr_version = "0.8.2"
description = "Open an agent in a new tab of this space, on the checkout or a fresh worktree"
platforms = ["macos", "linux"]

[[build]]
command = ["go", "build", "-o", "bin/agent-tab", "./cmd/agent-tab"]

[[actions]]
id = "new"
title = "New agent tab here"
contexts = ["workspace", "pane"]
command = ["./bin/agent-tab", "new"]

[[panes]]
id = "picker"
title = "New agent tab"
placement = "popup"
width = "70%"
height = 16
command = ["./bin/agent-tab", "picker"]
```

`new` is the headless action a key binds to. It only does
`herdr plugin pane open --plugin momepp.agent-tab --entrypoint picker`,
because a popup is the only entrypoint that gets a TTY. With `--dry-run` it
skips the popup and prints the three commands the picker would run for the
given `--agent/--where/--branch` flags (used by tests and by hand).

## Flow

```
Ctrl-a n
 └─ action new ─► popup picker
       1. agent   : herdr's kind list ∩ executables on PATH   (claude / omp / opencode today)
       2. where   : local · <current branch>   |   worktree · new branch
       3. branch  : (worktree only) input, placeholder = git-flow feature prefix
       └─ worktree ? git worktree add <root>/.worktrees/<slug> -b <branch> <base>
       └─ herdr tab create --workspace $HERDR_WORKSPACE_ID --cwd <dir> --label <label> --focus
       └─ herdr agent start <name> --kind <kind> --pane <root_pane.pane_id>
```

### Context

- Workspace: `HERDR_WORKSPACE_ID`.
- Working directory: the focused pane's `cwd` from `HERDR_PLUGIN_CONTEXT_JSON`
  (a popup has no `HERDR_PANE_ID`); fall back to `herdr pane current`.
- Repo root: `git rev-parse --show-toplevel` from that cwd. Failure ⇒ not a
  repo ⇒ the *where* step is skipped and the tab opens at the cwd.

### Agent list

The kinds come from herdr itself — `herdr agent start --help` lists
`[possible values: …]`; parse that rather than hard-coding — filtered to those
found on `PATH`. The last chosen kind is stored in
`$HERDR_PLUGIN_STATE_DIR/last-agent` and preselected.

### Branch, base, slug

| | Source | Fallback |
|---|---|---|
| prefix placeholder | `gitflow.prefix.feature` | `""` |
| base ref | `gitflow.branch.develop` | current branch |
| after creating | `git config gitflow.branch.<branch>.base <base>` if git-flow is configured | nothing |

`slug` = branch with every `/` → `-`, lower-cased, non `[a-z0-9_-]` dropped.
Tab label = slug (worktree) or the agent kind (local). Agent name =
`<kind>-<slug>` truncated to 32 chars and made unique among live agents by a
numeric suffix if needed (herdr requires `[a-z][a-z0-9_-]{0,31}`, unique).

### Worktree directory

`<root>/.worktrees/<slug>`. Before creating, if `git check-ignore -q .worktrees`
fails, append `.worktrees/` to `.git/info/exclude` — never to a tracked
`.gitignore`. Directory already present ⇒ refuse and show the path.

## Errors

Every failure is shown inside the popup and leaves nothing half-done:

| Failure | Behaviour |
|---|---|
| not a git repo | "where" step skipped; local tab at cwd |
| branch already exists | offer "open a worktree on the existing branch" (`git worktree add <dir> <branch>`, no `-b`) or cancel |
| worktree dir exists | refuse with the path |
| `git worktree add` fails | show git's stderr; no tab created |
| `tab create` fails | show the error; worktree stays (it is valid state); message says so |
| `agent start` times out / fails | tab stays open at a shell; message says the agent did not start |

## Testing

- `internal/gitx`, `internal/slug`: `go test` against temp repositories built in
  `t.TempDir()` — root/branch detection, git-flow prefix/base, exclude append,
  worktree add, existing-branch and existing-dir refusal.
- `internal/herdr`: `HERDR_BIN_PATH` pointed at a fake script that appends its
  argv to a log and replays canned JSON (`tab create` → `root_pane.pane_id`,
  `agent start` → ok). Assert the exact argv sequence for local and worktree.
- `agent-tab new --dry-run --agent claude --where worktree --branch feature/x`
  prints the three commands; golden-tested.
- Manual: `herdr plugin link`, `Ctrl-a n` in `badminton-platform` (no git-flow
  config ⇒ base = `develop`), both modes; then `git worktree list` and
  `herdr agent list` confirm the result.

## Dotfiles side (`feature/herdr-native-workflow`)

- `herdr plugin uninstall cloudmanic.herdr-plus`; remove its two bindings, the
  `herdr/plugins/config/cloudmanic.herdr-plus/` templates, and the `.gitignore`
  carve-out for them.
- Add `[[keys.command]] key = "prefix+n" type = "plugin_action"
  command = "momepp.agent-tab.new"`.
- `herdr-keymap.md`: `n` = new agent tab here; note that `G` and
  `herdr worktree create` make a space per worktree and are not the workflow.

## Decisions and why

- **Tab, not space.** The user's model is space = project. herdr's built-in
  worktree flow and every surveyed plugin (`herdr-plus`, `mkdir700/herdr-plugin-worktree`,
  `tdi/herdr-worktree-*`) create a space, so a plugin is required.
- **Own plugin, not a `bin/` script.** Same reach (popup + socket API) but
  installable, testable, and reusable from any machine with one command.
- **Go.** Matches the plugins already installed (auto-title, herdr-plus), one
  static binary, `huh` gives arrow-key forms for free.
- **`.worktrees/`, not `.claude/worktrees/`.** superpowers defaults to
  `.worktrees/` at the project root; sharing it means one place to prune.
- **`.git/info/exclude`, not `.gitignore`.** The plugin must not create diffs
  in the user's repositories.
- **Agent list from herdr, not hard-coded.** herdr adds kinds between releases;
  the plugin should not need a release to follow.
