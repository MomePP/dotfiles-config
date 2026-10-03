# OMP pstack port — design

## Goal

Run Lauren Tan's pstack (`poteto-mode`, its playbooks, principles, and review
panels) as the default workflow in OMP (driven through Paseo), replacing the
superpowers workflow for OMP only. Claude Code keeps superpowers unchanged.

Success means:

- An OMP session routes multi-file, design, and unknown-cause bug work through
  `poteto-mode` without being asked, dispatches subagents through OMP's `task`
  tool, and never reaches for Claude Code or Pi tool names that do not exist.
- The skills track upstream with no hand maintenance beyond merging a sync PR.
- Push, force-push, PR creation, arming auto-merge, and merging still ask first.
- Claude Code behavior is byte-for-byte the same instruction content as before.

## Decisions and rationale

| Decision | Choice | Why |
|---|---|---|
| Port base | `michael-denyer/pstack-claude` skills, copied verbatim | Already translated from Cursor primitives to Claude Code terms; synced to upstream `cursor/plugins` `23e4138` (0.15.6) on 2026-10-03; 950+ stars, tagged releases. |
| Translation | One mapping rule, no skill edits | Existing OMP ports (negoro26, Zukitata03, Jrecos, cang-pham) rewrite skill text; negoro26's sed/patch sync broke on upstream 0.15.6, Zukitata03's auto-update has failed since 2026-09-23, Jrecos pins OMP 18.3.4 and upstream 0.15.0. Unedited files sync as a plain copy. The current superpowers setup already runs on OMP through a mapping layer. |
| Runtime code | None | Routing ships as an always-apply plugin rule (system prompt, survives compaction). pstack-claude's Pi extension is not used: it registers `agent`/`ask_user_question`/`schedule_wakeup` and spawns `pi --mode rpc` children, duplicating OMP's `task`/`ask`/heartbeat. |
| Repo | New public repo `MomePP/pstack-omp`, README marks personal use | Marketplace add needs no credentials; MIT permits it. |
| Local checkout | `~/Developer/llm-stuff/pstack-omp` | Beside `claude-hud`, `tweakcc`. |
| Shared rules | Split `claude-code/CLAUDE.md` into fragments | One source of truth; OMP imports only the fragments that do not mandate superpowers. |
| Autonomy | User guardrails win | pstack autonomy for reversible local work; push/PR/merge actions ask first. |
| Artifacts | pstack defaults | pstack places todo files and decision trails itself; `.claude/` keeps notes and knowledges only. No mandatory spec/plan per feature in OMP. |

## Part 1 — plugin repo `MomePP/pstack-omp`

### Layout

```
.omp-plugin/marketplace.json
plugin/
  skills/                    synced verbatim from pstack-claude plugins/pstack/skills
  agents/poteto-agent.md
  agents/comment-sicko.md
  rules/pstack-routing.md
  rules/pstack-omp-tools.md
upstream.lock.json
scripts/sync.sh
scripts/check.sh
.github/workflows/sync.yml
.github/workflows/check.yml
README.md
LICENSE
NOTICE.md
```

`plugin/skills/` is sync output only. Every OMP-specific file lives outside it,
so a sync never conflicts with local work.

### Catalog

`.omp-plugin/marketplace.json`: marketplace `pstack-omp`, one plugin `pstack`,
`source: "./plugin"`, `version: "<pstack-claude VERSION>-omp.<n>"` (first
release `0.9.64-omp.1`). The catalog `version` changes on every sync and every
local release, because `omp plugin upgrade` only compares catalog versions.
`<n>` resets to 1 when the upstream version changes and increments for local
changes on the same upstream version.

### Agents (OMP task-agent format)

- `poteto-agent`: `name`, `description` from upstream, `autoloadSkills:
  [poteto-mode]`, no `model` (inherits the parent's model; callers pass
  `model` per role). Body: operate as poteto-mode; navigate to a leaf
  `principle-*` skill whenever applying that principle.
- `comment-sicko`: upstream body verbatim, `tools: read, grep, glob, bash`
  (read-only reviewer; may run `git diff`).

### Routing rule — `rules/pstack-routing.md`

Frontmatter `alwaysApply: true`. Content is pstack-claude's
`hooks/session-start-context.md` rewritten for OMP:

- invoke `skill://poteto-mode` (not `pstack:poteto-mode`) for tasks that touch
  more than one file or change a signature other files call, involve a design
  or architecture choice, or are a bug of unknown cause or a performance issue;
  work directly on smaller tasks and verify on the real artifact;
- enter `tdd`, `architect`, `how`, `why`, `arena`, `interrogate` directly when
  the intent is already that specific;
- pstack skills are written in Claude Code terms: before following any step
  that names a Claude tool, a `pstack:` agent or skill, a Claude model alias, or
  a Claude path, read `rule://pstack-omp-tools`;
- ignore `skills/poteto-mode/references/pi-tools.md` and `codex-tools.md`:
  OMP is neither Pi nor Codex;
- user instructions (AGENTS.md, direct requests) take precedence.

Opt-out: `disabledExtensions` entry for the rule, or `omp plugin disable`.

### Mapping rule — `rules/pstack-omp-tools.md`

Frontmatter `description` only (rulebook bucket, readable as
`rule://pstack-omp-tools`). Content:

| pstack / Claude Code | OMP |
|---|---|
| `Skill` tool, `pstack:<skill>`, `/<skill>` | `read skill://<skill>`; user-side `/skill:<skill>` |
| `Agent`/`Task` tool, `subagent_type: "pstack:poteto-agent"` | `task` with `agent: "poteto-agent"`; N parallel agents = one `task` call with N `tasks[]` items |
| `subagent_type: "pstack:comment-sicko"` | `task` with `agent: "comment-sicko"`, no isolation (needs uncommitted changes) |
| `pstack:poteto-agent-<level>`, `pstack:effort-<level>` | `agent: "poteto-agent"` or default `task`, `model: "@<alias>:<level>"` |
| `general-purpose`, `Explore`, `Plan` | default `task` agent; `scout` for read-only exploration |
| `readonly: true` | state "do not edit files" in the task; prefer read-only agents (`scout`, `reviewer`) where they fit |
| `run_in_background: true` | OMP tasks are async; results auto-deliver; do not poll |
| `SendMessage` | `write agent://<id>` |
| `isolation: "worktree"` | per-task isolation as the `task` tool exposes it; otherwise separate output directories |
| `AskUserQuestion` | `ask` |
| `TaskCreate`/`TaskUpdate`/`TodoWrite` | `todo` |
| `ScheduleWakeup`, `/loop` | heartbeat (`create_heartbeat`) or a background job; never sleep-poll |
| `~/.claude/projects/<encoded-cwd>/` transcripts | `~/.omp/agent/sessions/<encoded-cwd>/` (`history://` for registered agents) |
| `run`, project `verify` skill | run the program directly and observe output; a project verify skill lives in `.omp/skills/verify/` |
| `plugin-dev:skill-development` | OMP skill conventions: `skills/<name>/SKILL.md` with `name` + `description` |
| `CLAUDE.md` / "your instructions file" | `~/.omp/agent/AGENTS.md` (user), `.omp/AGENTS.md` or `AGENTS.md` (project) |
| model aliases `opus`, `fable`, `sonnet`, `haiku` | `model: "@opus"` etc., resolved by same-named `modelRoles` |

Also stated: the `recall` and `reflect` skills are not OMP's memory tools of the
same name; read `skill://typescript-best-practices` before editing `*.ts` or
`*.tsx` (upstream `paths:` frontmatter has no OMP equivalent).

### Models

The README instructs adding four `modelRoles` to `~/.omp/agent/config.yml`
whose names equal the aliases the skills use:

```yaml
modelRoles:
  opus: anthropic/claude-opus-5-5:high
  fable: anthropic/claude-fable-5-1:high
  sonnet: anthropic/claude-sonnet-5-5:medium
  haiku: anthropic/claude-haiku-4-5:low
```

Multi-model panels (`arena`, `architect`, `interrogate`) run three models per
call; the README states the cost.

### Sync automation

- `upstream.lock.json`: `{ "repo", "tag", "commit", "version" }`.
- `scripts/sync.sh [tag]`: resolve the latest `v*` tag of pstack-claude (or the
  given one); shallow-clone it; `rsync --delete` `plugins/pstack/skills/` into
  `plugin/skills/`; copy upstream `LICENSE`, `LICENSE-cursor-team-kit`,
  `NOTICE.md`, `NOTICE-skills.md` into `upstream-licenses/`; write the lock;
  set catalog version to `<VERSION>-omp.1` when the upstream version changed.
  Idempotent: rerunning on the locked tag changes nothing.
- `.github/workflows/sync.yml`: daily cron and `workflow_dispatch`. Runs
  `sync.sh`, then `check.sh`. When the tree changed, opens or updates one PR
  on branch `sync/pstack-claude` via `peter-evans/create-pull-request`, title
  `chore(sync): pstack-claude <tag>`, body = check report and added/removed
  skills. A PR created with `GITHUB_TOKEN` does not trigger other workflows, so
  the gate result lives in the PR body, and the PR is a draft when the gate
  fails. The user merges manually.
- `.github/workflows/check.yml`: runs `check.sh` on push and pull_request.

### Gate — `scripts/check.sh`

Fails on:

1. a `plugin/skills/*/SKILL.md` without `name` or `description` frontmatter
   (OMP drops plugin skills without a description);
2. a `subagent_type: "pstack:<x>"` value where `<x>` is neither a shipped agent
   (`poteto-agent`, `comment-sicko`) nor an `effort-<level>` /
   `poteto-agent-<level>` form covered by the mapping rule;
3. a `pstack:<name>` skill reference with no `plugin/skills/<name>/`;
4. invalid JSON in the catalog or lock.

Prints added and removed skill names against the previous lock for the PR body.

## Part 2 — dotfiles (`~/.config`, branch `feature/omp-pstack`)

### CLAUDE.md split

Move sections of `claude-code/CLAUDE.md` into `claude-code/instructions/`,
text unchanged:

| Fragment | Content | Claude Code | OMP pstack |
|---|---|---|---|
| `workflow-superpowers.md` | Workflow for new work | yes | no |
| `artifacts-knowledge.md` | `.claude/` placement for notes and knowledges, placement rules | yes | yes |
| `artifacts-specs-plans.md` | specs vs plans, feature-done promotion, superpowers path redirect | yes | no |
| `branch-names.md` | git-flow branch naming | yes | yes |
| `edit-retries.md` | Edit-tool retries | yes | yes |
| `subagent-worktrees.md` | absolute paths for subagents in worktrees | yes | yes |
| `coding-behavior.md` | Coding behavior 1–5 incl. anti-slop delta | yes | yes |

`CLAUDE.md` keeps its title and intro, `@`-imports every fragment in the
original order, and keeps the `CODEGRAPH_START`/`CODEGRAPH_END` block inline
(the codegraph installer manages it by marker). Where the current "Knowledge &
plan artifacts" section interleaves the two artifact topics, the split keeps
each sentence's wording and only regroups it.

### New `omp/AGENTS.md`

- OMP harness mapping, minus the superpowers lines (`superpowers:<name>`
  skills, the "Pi tool mapping" bootstrap note). Keeps tool-name mapping,
  `todo`, `task` agents (`debugger`, `refuter`, `researcher`, `reviewer`),
  `/code-review` → `reviewer`.
- pstack policy overrides:
  - pstack autonomy applies to reversible local work;
  - push, force-push, opening a PR, arming auto-merge, and merging always ask
    first, including inside babysit, shipping, and autopilot playbooks;
  - pstack chooses where todo files and decision trails go; durable knowledge
    still goes to `.claude/knowledges/`.
- `@`-imports of the five shared fragments.

### Runtime state (not in git)

```sh
omp plugin disable superpowers@superpowers-dev
omp plugin marketplace add MomePP/pstack-omp
omp plugin install pstack@pstack-omp
```

plus the four `modelRoles` in `~/.omp/agent/config.yml`. context-mode stays.

`~/.omp/agent/AGENTS.md` symlinks to `~/.config/omp/AGENTS.md`, so the
checked-out dotfiles branch selects the live OMP instructions. Revert: check out
`develop`, `omp plugin enable superpowers@superpowers-dev`,
`omp plugin disable pstack@pstack-omp`.

## Verification

1. `omp plugin marketplace add ~/Developer/llm-stuff/pstack-omp`, install; a
   fresh `omp -p --no-session` lists the pstack skills, the always-apply
   routing rule, `rule://pstack-omp-tools`, and agents `poteto-agent` and
   `comment-sicko`.
2. One real poteto-mode investigation dispatches `task` with
   `agent: "poteto-agent"` and an `@fable` or `@opus` model, and never calls a
   nonexistent `agent`/`Agent` tool.
3. `claude -p` quotes a sentence from a moved fragment, proving Claude Code
   still loads the split CLAUDE.md.
4. `workflow_dispatch` of `sync.yml` on the locked tag produces no PR;
   `check.sh` passes on the synced tree and fails on a seeded bad reference.

## Risks

- Marketplace-installed plugin `agents/` discovery is documented ambiguously
  (`omp://task-agent-discovery.md` excludes marketplace roots from extension
  roots but exempts OMP-origin installs from the Claude-plugin opt-in;
  negoro26 saw no discovery on omp 18.1.13). Verification step 1 decides.
  Fallback: symlink the two agents into `~/.omp/agent/agents/`, tracked in
  dotfiles.
- Plugin `rules/` loading from a marketplace install is documented for
  extension package roots; same verification step and the same fallback
  (copy the rules into `~/.omp/agent/rules/`).
- Runtime translation costs tokens and can be missed by the model; the gate
  catches structural drift, not semantic drift. The sync PR diff is the review
  point.
- Upstream pstack-claude may add new Claude-only tools; the gate does not know
  every tool name. Unknown names surface in the sync PR diff.
