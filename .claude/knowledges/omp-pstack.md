# OMP runs pstack (via MomePP/pstack-omp)

OMP (driven through Paseo) uses Lauren Tan's pstack as its workflow instead of
superpowers. Claude Code still uses superpowers. The two share rule fragments.

## Pieces

| Piece | Where | What |
|---|---|---|
| Plugin repo | `github.com/MomePP/pstack-omp` (public, personal use), checkout `~/Developer/llm-stuff/pstack-omp` | OMP marketplace `pstack-omp`, plugin `pstack`, `source: ./plugin` |
| Skills | `plugin/skills/` | Copied verbatim from `michael-denyer/pstack-claude` release tags by `scripts/sync.sh`. Never hand-edited. |
| Routing rule | `plugin/rules/pstack-routing.md` (`alwaysApply`) | Route multi-file / design / unknown-cause bug / perf work through `skill://poteto-mode`; inline Claude→OMP translations; playbook steps go into `todo`, skipped steps are `drop`ped with a stated `skip: <reason>` |
| Mapping rule | `plugin/rules/pstack-omp-tools.md` (`rule://pstack-omp-tools`) | Full Claude Code → OMP table (`Agent`→`task`, `AskUserQuestion`→`ask`, `TodoWrite`→`todo`, transcripts→`~/.omp/agent/sessions`, …) |
| Agents | `plugin/agents/poteto-agent.md` (`autoloadSkills: [poteto-mode]`), `comment-sicko.md` (upstream body) | Marketplace installs do surface plugin `agents/` and `rules/` on omp 18.5.0 |
| Gate | `scripts/check.sh` | Fails on: no skills, skill without `name`/`description`, unknown `pstack:` agent or skill ref, rule/agent `skill://` or `autoloadSkills` ref with no skill, invalid catalog/lock JSON, catalog without version |
| Version | `.omp-plugin/marketplace.json` | `<pstack-claude VERSION>-omp.<n>`: new upstream VERSION → `.1`; new upstream commit, same VERSION → `n+1`; local changes → bump `n` by hand. `omp plugin upgrade` only sees catalog version changes. |

Why skills stay verbatim: every other OMP port (negoro26, Zukitata03, Jrecos,
cang-pham) rewrote skill text and their upstream syncs broke. Unedited files
sync as a plain copy; translation happens at runtime through the two rules.
pstack-claude's own Pi extension is not used: it duplicates OMP's
`task`/`ask`/heartbeat tools.

## Sync chain (no manual step unless the gate fails)

1. `sync.yml` runs daily (and on `workflow_dispatch`): `sync.sh` to the latest
   `v*` tag, `check.sh`, then `peter-evans/create-pull-request@v8` opens
   `sync/pstack-claude` → `main`. Gate fail → draft PR, no auto-merge.
2. The PR is opened with secret `SYNC_TOKEN` (fine-grained PAT, this repo only,
   Contents + Pull requests read/write). A PR opened with `GITHUB_TOKEN` does
   not start `check` without maintainer approval, so it would never merge.
   Missing secret → falls back to `GITHUB_TOKEN` (manual approval). Expired
   token → PR step fails; renew and update the secret.
3. Gate pass → `gh pr merge --auto --squash`. GitHub merges once the required
   `check` passes. Repo settings: Allow auto-merge, delete head branches;
   ruleset `main` requires status `check` (GitHub Actions, integration 15368),
   blocks deletion and force-push, Repository admin bypasses (direct pushes to
   `main` work, shown as bypassed).
4. OMP `marketplace.autoUpdate: auto` (`~/.omp/agent/config.yml`) upgrades the
   plugin at next OMP start (catalogs older than 24h refreshed first). Applies
   to every marketplace plugin, not just pstack.

When the gate fails, fix on `main` and rerun the workflow: each run rebuilds
`sync/pstack-claude` from `main`, so commits pushed to that branch are lost.
`check.yml` runs on push to `main` and on PRs, with `actions/checkout@v7`
(Node 24).

## Dotfiles side

- `claude-code/CLAUDE.md` is only `@~/.config/claude-code/instructions/*.md`
  imports plus the CODEGRAPH block; expanded it is byte-identical to the
  pre-split file. Fragments: `workflow-superpowers`, `artifacts` (Claude only);
  `branch-names`, `edit-retries`, `subagent-worktrees`, `coding-behavior`
  (shared).
- `omp/AGENTS.md` (symlinked as `~/.omp/agent/AGENTS.md`, which shadows any
  `~/.claude/CLAUDE.md` in OMP) has the OMP harness mapping, pstack policy
  overrides, an OMP-only Artifacts section, the four shared imports, and its own
  copy of the CODEGRAPH block.
- pstack policy: autonomy for reversible local work only; push, force-push,
  opening a PR/MR, arming auto-merge, and merging always ask first, including
  in babysit/shipping/autopilot/orchestrate playbooks.
- `modelRoles` `opus`, `fable`, `sonnet`, `haiku` exist so skill model aliases
  resolve as `model: "@fable"` etc. Panels (`interrogate`, `arena`,
  `architect`) need these to point at different models to stay diverse.
- Runtime: `superpowers@superpowers-dev` disabled, `pstack@pstack-omp`
  installed; context-mode unchanged.

Revert to superpowers in OMP: restore the pre-pstack `omp/AGENTS.md` from git,
`omp plugin enable superpowers@superpowers-dev`,
`omp plugin disable pstack@pstack-omp`.

## Gotchas

- Quitting and reopening Paseo resumes each OMP agent's transcript but rebuilds
  its system prompt from disk, so plugin and AGENTS.md changes apply from the
  next turn. Earlier turns are not redone; start a new agent for a clean test.
- Without an explicit model rule the agent dispatched panel reviewers with
  `model: null`, collapsing the panel to one model. The inline translation in
  the routing rule fixed it; keep it there, not only in the rulebook rule.
- Without the todo rule the agent followed a playbook's substance but skipped
  process steps silently.
- In workflow YAML, a plain `run:` scalar containing ` #` is cut off as a
  comment; use a block scalar (`run: |`).
- Rulesets with required status checks also block creating matching branches
  unless `do_not_enforce_on_create` is set.
- Cost: Actions and autoUpdate use no model tokens. In sessions, the always-on
  rule + AGENTS.md is ~1.5k tokens (cached); `poteto-mode` adds ~6–7k when
  routed; subagents and 3-model panels are the real spend.
