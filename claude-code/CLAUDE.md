# Global instructions

## Knowledge & plan artifacts → `.claude/` only

When asked to write a plan, design doc, research note, or any persistent
non-source artifact for a project, always place it under that project's
`.claude/` directory. Use these subpaths:

- `.claude/plans/` — implementation **plans**: the HOW — step-by-step tasks,
  rewrite plans, phase breakdowns. Plans are **working documents with a
  lifecycle** — see "Feature done → promote to knowledge, delete spec+plan"
  below. (The old `.claude/plans/done/` archive convention is retired; do not
  archive, delete.)
- `.claude/notes/` — investigation notes, debugging logs, research summaries
  (single session, point-in-time observations).
- `.claude/knowledges/` — durable, multi-session findings: hard-won facts,
  protocol gotchas, "this caused us 3 hours, don't repeat" entries.
  Promote a note here once it's been re-referenced in a later session
  or the lesson generalises beyond one bug.
- `.claude/specs/` — protocol specs, API contracts, RFCs, **and design docs**:
  the WHAT/WHY — requirements, architecture, the output of a brainstorming/
  design pass, *before* it's decomposed into implementation steps.
- `.claude/tmp/`   — ephemeral artifacts: panic dumps, raw log captures,
  scratch test outputs, intermediate data. Anything safe to wipe between
  sessions. Do not commit; ensure `.claude/tmp/` is gitignored per project.

### Spec vs plan — don't conflate them

A **spec/design doc** (the WHAT/WHY) and an **implementation plan** (the HOW)
are different artifacts with different homes. One feature usually produces
**both**: a spec in `.claude/specs/` and a plan in `.claude/plans/`. A design
doc is NOT a plan just because it describes upcoming work — if it states
requirements, architecture, or trade-offs rather than ordered build steps, it
is a spec → `.claude/specs/`. Do not file a design doc under `.claude/plans/`.

### Feature done → promote to knowledge, delete spec+plan

Specs and plans are **scaffolding for building the feature, not permanent
documentation**. They may live on the feature branch (and appear in its MR)
while work is in progress, but they must not outlive the feature — a merged
tree carrying stale plans reads as current guidance and misleads later
sessions.

When a feature is finished (final review passed, pending verification done,
MR ready to merge or merged):

1. **Promote**: fold the durable content of the feature's spec(s) and plan(s)
   into `.claude/knowledges/<topic>.md` — one file per topic, merged into an
   existing knowledge file when the topic already has one. Carry over the
   final WHAT/WHY (contracts, protocols, wire formats, constants), the
   decisions and their rationale, and any gotchas discovered during
   implementation. Write it as the **final state of the system**, not as
   planning history ("will add X" → "X works like…").
2. **Delete**: `git rm` the feature's spec, plan, and any resolved companion
   docs (test protocols with all boxes ticked, completed trackers) in the
   same commit as the knowledge promotion (e.g.
   `docs(knowledge): promote <feature> spec+plan to knowledge, drop working docs`).
   Long-lived trackers with open items (e.g. a deprecation tracker) stay.
3. **Timing**: prefer doing this as the feature branch's closing commit so
   the MR history preserves the spec/plan for archaeology but the merged
   tree carries knowledge only. If the branch already merged, do it as a
   follow-up commit on the base branch.

Do this proactively at feature completion — it is part of finishing, not an
optional cleanup.

### Superpowers plugin paths → redirect into `.claude/`

The Superpowers skills default to writing under `docs/superpowers/`:
`brainstorming` saves the design doc to
`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`, and `writing-plans`
saves to `docs/superpowers/plans/YYYY-MM-DD-<feature>.md`. **Override both**:

- brainstorming design doc / spec → `.claude/specs/`
- writing-plans implementation plan → `.claude/plans/`

Both skills state "user preferences for location override this default," so
honoring this rule is sanctioned, not a deviation. **Strip their date prefix**
— plain topic-led kebab-case filenames per rule 3 below (e.g.
`per-game-shuttlecock-type-design.md`, NOT `2026-06-10-per-game-…`); both the
directory and the filename change.

## Scratch files → `.claude/tmp/` only, never `/tmp`

ALL transient/scratch files — redirected command output (`cmd > x.txt`),
intermediate captures, generated-then-`cp`'d files, analysis dumps — go in
the project's `.claude/tmp/` directory. **Never write to the system `/tmp`.**

- Create `.claude/tmp/` if missing (`mkdir -p .claude/tmp`); do not ask.
- It must be gitignored per project (add `.claude/tmp/` to `.gitignore`).
- Reason: `/tmp` is outside the workspace, isn't visible to the user, and
  files written there by a sandboxed tool (e.g. a Python `ctx_execute`
  subprocess) are silently discarded — leading to "file not found" on a
  later `cp`/`Read`. Keeping scratch in `.claude/tmp/` keeps it on the
  real host filesystem, inside the repo, and easy to clean up.

Rules:

1. Never drop these files at the repo root or in `docs/` unless the user
   explicitly names that path.
2. Create the `.claude/` subdirectory if it does not exist; do not ask.
3. Filenames are kebab-case, end in `.md`, lead with the topic
   (e.g. `gdxlib-rewrite.md`, not `plan-for-gdxlib-rewrite-v2.md`).
4. The "no docs/READMEs unless asked" rule still applies to project-level
   docs (top-level `README.md`, `docs/*.md`). The `.claude/` path is the
   sanctioned exception for assistant-authored knowledge.
5. If the user says "write the plan" without a path, default to
   `.claude/plans/<topic>.md` and tell them where it landed.

## Branch names → read git-flow config, don't copy nearby branches

Before creating a branch, check whether the repo has git-flow initialised:

```bash
git config --get-regexp '^gitflow\.'
```

If it returns anything, **its prefixes are the convention** — typically
`feature/`, `bugfix/`, `release/`, `hotfix/`, `support/`, with
`gitflow.branch.master` and `gitflow.branch.develop` naming the two long-lived
branches. Use them, and record the base the way the repo already does:

```bash
git config gitflow.branch.<full-branch-name>.base develop   # hotfix/* uses master
```

Do **not** infer the prefix by pattern-matching branches in `git branch -a`.
A repo can accumulate one-off branches that violate its own convention
(e.g. a stray `fix/…` alongside four conforming `bugfix/…`), and copying the
outlier silently spreads it. The config is authoritative; the branch list is not.

Choosing between prefixes: `feature/` adds capability, `bugfix/` repairs
behaviour on `develop`, `hotfix/` repairs a release and branches from `master`.
When work is genuinely mixed, pick by what the merge is *for* and say which
you chose, so the user can redirect cheaply — renaming an unpushed or
freshly-pushed branch is trivial, renaming one with an open MR is not.

## Edit-tool retries

When the `Edit` tool returns "String to replace not found in file",
do not stop and ask the user to continue. The mismatch is almost
always single-character drift between in-context memory and the
file on disk (a hyphen, a renamed identifier, a reflowed comment).

Recovery, no prompting required:

1. `Read` the target region from disk to get the exact bytes.
2. Rebuild `old_string` from those bytes verbatim.
3. Retry the `Edit`.

Only escalate to the user if a second attempt — built from a fresh
`Read` — also fails. The same rule applies to `Write` failures
caused by stale file-state tracking: re-`Read`, then retry.

## Coding behavior

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
