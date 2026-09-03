# herdr keymap (prefix = `Ctrl-a`)

The effective bindings from `herdr/config.toml` plus the herdr defaults it does
not override. Every key below is pressed after `Ctrl-a`. Capitals mean Shift.

## Workflow (herdr-native, since 2026-09-03)

One herdr **space per project**; inside it one **tab per job** — the agent, an
`nvim`, a `lazygit`. Nothing launches from nvim (herd.nvim is disabled on this
branch). New work starts from the projects picker.

| Key | Action |
|---|---|
| `g` | **herdr-plus projects picker** — `Enter` opens the project on its checkout, `ctrl+g` inside the picker opens it as a **new worktree** (prompt for a branch name; empty lets herdr pick `worktree/…`) |
| `.` | herdr-plus quick actions (one-off commands, fuzzy) |
| `N` | new space on the current directory (herdr built-in) |
| `G` | new space on a fresh worktree (herdr built-in, no template) |

Project templates: `herdr/plugins/config/cloudmanic.herdr-plus/projects/*.toml`
(one file per project). Worktree layouts: `…/worktrees/*.toml` — `repo = "*"`
is the fallback, `repo = "<name>"` overrides it per repo.

## Spaces

| Key | Action |
|---|---|
| `w` | space picker |
| `Ctrl-w` | omni-jump (goto: spaces / tabs / agents tree) |
| `1..9` | switch to space N |
| `Ctrl-k` / `Ctrl-j` | previous / next space |
| `W` | rename space |
| `X` | close space |

## Tabs

| Key | Action |
|---|---|
| `Ctrl-n` | new tab |
| `Ctrl-h` / `←` | previous tab |
| `Ctrl-l` / `→` | next tab |
| `T` | rename tab |
| `Ctrl-x` | close tab |

`1..9` is deliberately *not* tab switching — the number row is spaces.

## Panes

| Key | Action |
|---|---|
| `\|` or `Enter` | split right |
| `_` or `Shift-Enter` | split down |
| `h` `j` `k` `l` | focus pane left / down / up / right |
| `Tab` / `Shift-Tab` | cycle panes |
| `;` | last pane |
| `z` | zoom (fullscreen) toggle |
| `x` | close pane |
| `P` | rename pane |
| `R` | resize mode |
| `e` | edit scrollback in `$EDITOR` |

## Agents

| Key | Action |
|---|---|
| `Shift-1..9` | focus agent N in the sidebar |
| `↑` / `↓` | previous / next agent |
| `o` | open the notification's target |

## Review & annotate (plugins)

| Key | Plugin | Action |
|---|---|---|
| `a` | annotate | comment on the selected terminal text |
| `A` | annotate | copy all annotations as Markdown context |
| `H` | hunk-diff | review the working-tree changes in hunk |
| `S` | hunk-diff | send the review comments back to the agent |
| `C` | hunk-diff | review the last commit |

Unbound but in the action menu: hunk `review:staged`, `review:branch`,
`review:stash`; annotate `last` (agent's last message), `open`, `manage`.

## Session

| Key | Action |
|---|---|
| `?` | help — every active binding |
| `s` | settings |
| `r` | reload `config.toml` |
| `b` | toggle sidebar |
| `q` | detach |

## Plugin housekeeping

- `herdr plugin list` / `enable` / `disable` / `uninstall <id>`
- `herdr plugin action list` — every action id you can bind with
  `type = "plugin_action"` in `[[keys.command]]`
- Plugins only **start when the server restores a session**: after installing,
  `herdr server stop` then relaunch `herdr`. Reopening a terminal is not enough.
- `herdr update` must run from outside a herdr session.
- hunk-diff's `setup-keys` action writes its own defaults (`S`, `A`) over
  settings/annotate — the bindings above were written by hand instead.
