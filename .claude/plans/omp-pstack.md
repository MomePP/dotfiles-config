# OMP pstack port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship `MomePP/pstack-omp`, an OMP marketplace plugin carrying pstack-claude's skills verbatim plus OMP routing/mapping rules and agents with a daily upstream-sync PR, and switch the OMP dotfiles setup from superpowers to it.

**Architecture:** Plugin repo = synced `plugin/skills/` + hand-written `plugin/{agents,rules}/` + bash `sync.sh`/`check.sh` + two GitHub workflows. Dotfiles = `claude-code/CLAUDE.md` split into import-only fragments, new pstack `omp/AGENTS.md`, runtime plugin toggles.

**Tech Stack:** bash, jq, rsync, git, GitHub Actions (`peter-evans/create-pull-request@v7`), OMP 18.5.0 marketplace plugins, Claude Code `@` imports.

**Spec:** `.claude/specs/omp-pstack-design.md`

## Global Constraints

- Two checkouts, absolute paths only: plugin repo `/Users/momeppkt/Developer/llm-stuff/pstack-omp`; dotfiles `/Users/momeppkt/.config` on branch `feature/omp-pstack`. Never touch other checkouts.
- `plugin/skills/` is written only by `scripts/sync.sh`. No hand edits.
- Upstream: `https://github.com/michael-denyer/pstack-claude`, tags `v*`, first sync `v0.9.64`; skills source dir `plugins/pstack/skills/`; version from root `VERSION`.
- Catalog: marketplace `pstack-omp`, plugin `pstack`, `source: "./plugin"`, version `<VERSION>-omp.<n>`, first `0.9.64-omp.1`.
- Shipped agents: `poteto-agent`, `comment-sicko`. Rules: `pstack-routing` (alwaysApply), `pstack-omp-tools` (description only).
- Model aliases resolved by same-named `modelRoles`: `opus: anthropic/claude-opus-5-5:high`, `fable: anthropic/claude-fable-5-1:high`, `sonnet: anthropic/claude-sonnet-5-5:medium`, `haiku: anthropic/claude-haiku-4-5:low`.
- Push, PR creation, and merging in the dotfiles repo ask the user first. Creating and pushing the new plugin repo is approved (user requested it).
- Conventional commits, lowercase scope (`feat(sync):`, `docs(omp):`, `refactor(claude-code):`).
- Repo is public; README states personal use and credits Lauren Tan (pstack) and Michael Denyer (pstack-claude). MIT; upstream license/notice files ship in `upstream-licenses/`.

## Review Focus

1. Marketplace install does not surface `plugin/agents/` or `plugin/rules/` → poteto-mode delegates to a missing agent; Task 4 smoke pins discovery and applies the symlink fallback.
2. Model follows `pi-tools.md` (OMP is a Pi fork) and calls a nonexistent `agent` tool → Task 7 smoke greps the session transcript for tool names.
3. Claude Code silently drops external `@~/…` imports in non-interactive runs → Task 6 probes a sentence from a fragment through `claude -p`.
4. New repo default: Actions may not create PRs → Task 5 enables the workflow permission and dispatches the sync.
5. Upstream removes or renames a skill → stale directory stays and catalog version fails to bump, so `omp plugin upgrade` sees nothing → Task 2 fixture test covers `--delete` and the version bump.

---

### Task 1: Plugin repo scaffold and gate

**Files:**
- Create: `/Users/momeppkt/Developer/llm-stuff/pstack-omp/.omp-plugin/marketplace.json`
- Create: `…/pstack-omp/scripts/check.sh`
- Create: `…/pstack-omp/tests/check.test.sh`
- Create: `…/pstack-omp/LICENSE` (MIT, © 2026 MomePP), `…/.gitignore`

**Interfaces:**
- Produces: `scripts/check.sh [ROOT]` (default repo root). Exit 0 = pass, 1 = fail. Prints one `FAIL: <reason>` line per violation and `OK: <n> skills, <m> agents` on success. Reads `ROOT/plugin/skills/*/SKILL.md`, `ROOT/plugin/agents/*.md` (agent name = frontmatter `name`), `ROOT/.omp-plugin/marketplace.json`, `ROOT/upstream.lock.json` (skipped when absent).
- Produces: catalog JSON `{ name: "pstack-omp", owner: { name: "MomePP" }, metadata: { description }, plugins: [{ name: "pstack", source: "./plugin", version, description, license: "MIT", homepage: "https://github.com/MomePP/pstack-omp" }] }`.

- [ ] **Step 1: `git init -b main` the repo; write catalog with version `0.0.0-omp.0` (sync sets the real one), LICENSE, `.gitignore` (`.DS_Store`).**
- [ ] **Step 2: Write `tests/check.test.sh`.** Builds temp fixture roots and asserts exit code plus a `FAIL:` substring per case:
  - `valid`: skill `a` with `name`+`description`, agent `poteto-agent.md` (`name: poteto-agent`), skill text referencing `subagent_type: "pstack:poteto-agent"`, `pstack:poteto-agent-high`, `pstack:effort-max`, `pstack:a` → exit 0.
  - `missing-description`: SKILL.md without `description:` → exit 1, `FAIL: plugin/skills/b/SKILL.md missing description`.
  - `unknown-agent`: text `subagent_type: "pstack:ghost"` → exit 1, `FAIL: unknown agent pstack:ghost`.
  - `dangling-skill`: text `pstack:nope` (not an agent form) → exit 1, `FAIL: unknown skill pstack:nope`.
  - `bad-json`: catalog `{` → exit 1, `FAIL: .omp-plugin/marketplace.json invalid JSON`.
- [ ] **Step 3: Run `bash tests/check.test.sh`** → every case fails (script missing).
- [ ] **Step 4: Implement `scripts/check.sh`.** `set -euo pipefail`; frontmatter = lines between the first two `---`; `pstack:<x>` tokens via `grep -rhoE 'pstack:[a-z0-9-]+'` over `plugin/skills`; classify each token: shipped agent name, `poteto-agent-<level>` / `effort-<level>` with level in `low|medium|high|xhigh|max` → ok; directory `plugin/skills/<x>` → ok; token inside `subagent_type: "…"` not matching agents → unknown agent; else unknown skill. `jq empty` for JSON validity.
- [ ] **Step 5: Run `bash tests/check.test.sh`** → `all 5 cases passed`.
- [ ] **Step 6: Commit** `feat(gate): add catalog and port gate`.

### Task 2: Upstream sync script

**Files:**
- Create: `…/pstack-omp/scripts/sync.sh`
- Create: `…/pstack-omp/tests/sync.test.sh`
- Create (by running sync): `…/plugin/skills/**`, `…/upstream-licenses/*`, `…/upstream.lock.json`

**Interfaces:**
- Consumes: catalog from Task 1.
- Produces: `scripts/sync.sh [TAG]`; env `PSTACK_CLAUDE_REPO` (default upstream URL). Writes `upstream.lock.json` = `{ "repo", "tag", "commit", "version" }`; sets `.plugins[0].version` to `<VERSION>-omp.1` only when lock `version` differs from the new `VERSION`; prints `synced <tag> (<commit7>)`, then `added: <skill>` / `removed: <skill>` lines. Latest tag = `git ls-remote --tags --sort=-v:refname "$repo" 'v*'` first non-`^{}` entry.

- [ ] **Step 1: Write `tests/sync.test.sh`.** Creates a local fixture git repo with `VERSION=0.0.1`, `plugins/pstack/skills/{a,b}/SKILL.md`, `LICENSE`, tag `v0.0.1`; copies the repo's `scripts/` and catalog into a temp plugin root; runs with `PSTACK_CLAUDE_REPO=<fixture>`. Assertions:
  - first run: `plugin/skills/a` and `b` exist; lock `.tag == "v0.0.1"`; catalog version `0.0.1-omp.1`; output contains `added: a` and `added: b`.
  - second run, same tag: `git status --porcelain` in the temp root is empty after committing run one (idempotent).
  - fixture removes `b`, adds `c`, `VERSION=0.0.2`, tag `v0.0.2`; run: `b` gone, `c` present, version `0.0.2-omp.1`, output has `removed: b` and `added: c`.
  - catalog hand-set to `0.0.2-omp.3`, rerun on `v0.0.2`: version stays `0.0.2-omp.3`.
- [ ] **Step 2: Run `bash tests/sync.test.sh`** → FAIL (no script).
- [ ] **Step 3: Implement `scripts/sync.sh`** (`git clone --depth 1 --branch "$tag"`, `rsync -a --delete`, license files copied when present, `jq` in-place writes via temp file, added/removed from `comm` of before/after directory listings).
- [ ] **Step 4: Run both test scripts** → pass.
- [ ] **Step 5: Run the real sync** `scripts/sync.sh v0.9.64`, then `scripts/check.sh`. Expected: `synced v0.9.64 (55430ba)`, catalog `0.9.64-omp.1`, check fails only on agents (no `plugin/agents/` yet: `FAIL: unknown agent pstack:poteto-agent`, `…comment-sicko`). That failure is expected until Task 3.
- [ ] **Step 6: Commit** `feat(sync): sync pstack-claude v0.9.64 skills` (scripts, tests, synced tree, lock, licenses).

### Task 3: OMP agents and rules

**Files:**
- Create: `…/plugin/agents/poteto-agent.md`, `…/plugin/agents/comment-sicko.md`
- Create: `…/plugin/rules/pstack-routing.md`, `…/plugin/rules/pstack-omp-tools.md`

**Interfaces:**
- Consumes: synced skills (`poteto-mode`, `typescript-best-practices`, upstream `agents/*.md` bodies from pstack-claude `v0.9.64` for wording).
- Produces: agent names `poteto-agent`, `comment-sicko`; rule names `pstack-routing`, `pstack-omp-tools` (filename-derived).

- [ ] **Step 1: `poteto-agent.md`** frontmatter `name: poteto-agent`, upstream `description`, `autoloadSkills: [poteto-mode]`; no `model`. Body per spec "Agents".
- [ ] **Step 2: `comment-sicko.md`** frontmatter `name: comment-sicko`, upstream `description`, `tools: read, grep, glob, bash`; body = upstream body verbatim.
- [ ] **Step 3: `pstack-routing.md`** frontmatter `alwaysApply: true`, `description: pstack routing for OMP`; body = the five bullets of spec "Routing rule", in the imperative.
- [ ] **Step 4: `pstack-omp-tools.md`** frontmatter `description: Claude Code → OMP mapping for pstack skills; read before following a step that names a Claude tool, pstack: agent or skill, model alias, or Claude path`; body = spec "Mapping rule" table plus its two trailing notes.
- [ ] **Step 5: Run `scripts/check.sh`** → `OK: 56 skills, 2 agents` (skill count = directories synced in Task 2).
- [ ] **Step 6: Commit** `feat(omp): add poteto-agent, comment-sicko, routing and mapping rules`.

### Task 4: Local install smoke (discovery)

**Files:** none in git unless the fallback triggers (then Task 7 tracks it).

- [ ] **Step 1:** `omp plugin marketplace add /Users/momeppkt/Developer/llm-stuff/pstack-omp && omp plugin install pstack@pstack-omp` → `omp plugin list` shows `pstack@pstack-omp 0.9.64-omp.1` enabled.
- [ ] **Step 2:** `omp -p --no-session --thinking off "Do not call tools. Print: (1) whether skill poteto-mode is listed, (2) the names of always-apply and rulebook rules, (3) every agent name in the task tool's Available Agents."` Expected: poteto-mode listed; `pstack-routing` text present; `pstack-omp-tools` listed; agents include `poteto-agent`, `comment-sicko`.
- [ ] **Step 3 (only if agents or rules missing):** record which surface failed in `.claude/notes/omp-pstack-discovery.md` (dotfiles); fallback for agents = symlinks `~/.omp/agent/agents/{poteto-agent,comment-sicko}.md → ~/.omp/plugins/node_modules/pstack/agents/…`; for rules = symlinks into `~/.omp/agent/rules/`. Rerun Step 2 until it passes. Tracking of the symlinks lands in Task 7.
- [ ] **Step 4:** remove the local marketplace (`omp plugin uninstall pstack@pstack-omp`, `omp plugin marketplace remove pstack-omp`) so Task 7 installs from GitHub.

### Task 5: Workflows, README, publish

**Files:**
- Create: `…/.github/workflows/check.yml`, `…/.github/workflows/sync.yml`, `…/README.md`

**Interfaces:**
- Consumes: `scripts/check.sh`, `scripts/sync.sh`, `tests/*.test.sh`.

- [ ] **Step 1: `check.yml`** on `push` and `pull_request`: checkout, `bash tests/check.test.sh`, `bash tests/sync.test.sh`, `bash scripts/check.sh`.
- [ ] **Step 2: `sync.yml`** on `schedule: cron '17 3 * * *'` and `workflow_dispatch`; `permissions: contents: write, pull-requests: write`. Steps: checkout; `scripts/sync.sh | tee sync.log`; `scripts/check.sh | tee check.log` with `continue-on-error`, capture outcome; build body from both logs; `peter-evans/create-pull-request@v7` with `branch: sync/pstack-claude`, `title: chore(sync): pstack-claude <tag from lock>`, `commit-message` same, `draft: ${{ check outcome == failure }}`, `delete-branch: true`. No PR when the tree is unchanged (action default).
- [ ] **Step 3: README** sections: personal-use notice; credits and license; install (`omp plugin marketplace add MomePP/pstack-omp`, `omp plugin install pstack@pstack-omp`); required `modelRoles` block (Global Constraints values); panel cost note; how routing works and the opt-out (`omp plugin disable` or `disabledExtensions`); sync flow and version scheme (`<upstream>-omp.<n>`, bump `<n>` for local changes); agent/rule discovery fallback if Task 4 needed it.
- [ ] **Step 4:** `gh repo create MomePP/pstack-omp --public --source . --push --description "Personal OMP port of pstack (via pstack-claude)"`; enable PR creation: `gh api -X PUT repos/MomePP/pstack-omp/actions/permissions/workflow -f default_workflow_permissions=write -F can_approve_pull_request_reviews=true`.
- [ ] **Step 5:** `gh run watch` the push-triggered `check` run → success. `gh workflow run sync.yml` then watch → success, `gh pr list` empty (locked tag is latest).
- [ ] **Step 6: Commit and push** `ci: add check and upstream sync workflows` and `docs: add README` (README may ride the same push as Step 4 if written first).

### Task 6: Split CLAUDE.md into fragments (dotfiles)

**Files:**
- Create: `/Users/momeppkt/.config/claude-code/instructions/{workflow-superpowers,artifacts,branch-names,edit-retries,subagent-worktrees,coding-behavior}.md`
- Modify: `/Users/momeppkt/.config/claude-code/CLAUDE.md`

**Interfaces:**
- Produces: fragment paths `~/.config/claude-code/instructions/<name>.md`, consumed by Task 7.

Fragments hold these exact line ranges of the current `CLAUDE.md`: workflow-superpowers `3-16`, artifacts `18-106`, branch-names `108-134`, edit-retries `136-151`, subagent-worktrees `153-171`, coding-behavior `173-247` (re-read to confirm each range ends before the blank line that precedes the next `## `; blank separators stay in `CLAUDE.md`).

- [ ] **Step 1:** create the six fragments from those ranges; replace each range in `CLAUDE.md` with one line `@~/.config/claude-code/instructions/<name>.md`. Title, blank separators, `---`, and the CODEGRAPH block stay.
- [ ] **Step 2: Verify expansion is identical:** expand each `@~/.config/claude-code/instructions/*.md` line with the file contents and `diff` against `git show HEAD:claude-code/CLAUDE.md` → no output.
- [ ] **Step 3: Verify Claude Code loads imports:** `claude -p "Quote verbatim the sentence in your global instructions that starts with 'When the Edit tool returns'. Output only the quote."` → returns that sentence (from `edit-retries.md`). If empty or paraphrased-missing, stop and report (Review Focus 3).
- [ ] **Step 4: Commit** `refactor(claude-code): split CLAUDE.md into importable fragments`.

### Task 7: pstack OMP AGENTS.md and runtime switch

**Files:**
- Modify: `/Users/momeppkt/.config/omp/AGENTS.md`
- Create (only if Task 4 fallback triggered): tracked symlink setup, e.g. `omp/agents/` + doc line in AGENTS.md
- Runtime (untracked): `~/.omp/agent/config.yml` `modelRoles`, plugin state

**Interfaces:**
- Consumes: Task 6 fragment paths; published `MomePP/pstack-omp`.

- [ ] **Step 1: Rewrite `omp/AGENTS.md`** per spec "New `omp/AGENTS.md`": title `# Global instructions (OMP + pstack)`; OMP harness mapping without the two superpowers bullets; `## pstack policy` (three bullets); `## Artifacts` (OMP-only paragraph); `## Shared rules` with four `@~/.config/claude-code/instructions/…` imports (branch-names, edit-retries, subagent-worktrees, coding-behavior).
- [ ] **Step 2: Runtime:** add the four `modelRoles` to `~/.omp/agent/config.yml` (keep existing keys); `omp plugin disable superpowers@superpowers-dev`; `omp plugin marketplace add MomePP/pstack-omp`; `omp plugin install pstack@pstack-omp`.
- [ ] **Step 3: Smoke routing and dispatch:** in `/Users/momeppkt/.config`, `omp -p --session-dir /tmp/omp-pstack-smoke "How does paseo-repatch decide which app.asar patches to apply? Investigate."` Then inspect the newest jsonl in `/tmp/omp-pstack-smoke`: expect a `read` of `skill://poteto-mode`, a `task` call whose items use `agent: "poteto-agent"` or a pstack-routed agent with `model` `@opus`/`@fable`/`@sonnet`, and zero calls to tools named `agent`, `Agent`, `Skill`, `ask_user_question`. Expect no superpowers bootstrap text in the transcript.
- [ ] **Step 4: Guardrail probe:** `omp -p --no-session "Per your instructions, may you push or open a PR without asking? Answer yes or no and cite the rule."` → `no`, citing pstack policy.
- [ ] **Step 5: Commit** `feat(omp): switch OMP instructions to pstack` (plus fallback files if any). Delete `/tmp/omp-pstack-smoke`.

### Task 8: Finish — promote to knowledge

Run only after the user accepts the trial (the branch is the trial; merging is the user's call).

**Files:**
- Create: `/Users/momeppkt/.config/.claude/knowledges/omp-pstack.md`
- Delete: `.claude/specs/omp-pstack-design.md`, `.claude/plans/omp-pstack.md`, `.claude/notes/omp-pstack-discovery.md` (if created)

- [ ] **Step 1:** write the knowledge file as final state: repo, layout, sync flow and version scheme, mapping/routing rules, modelRoles, AGENTS.md structure and fragment table, revert procedure, discovery findings from Task 4, port comparison rationale.
- [ ] **Step 2: Commit** `docs(knowledge): promote omp-pstack spec+plan to knowledge, drop working docs`. Ask before pushing.
