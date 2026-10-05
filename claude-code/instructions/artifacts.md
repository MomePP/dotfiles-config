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

### Placement rules

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
