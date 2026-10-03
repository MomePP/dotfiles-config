# Global instructions (OMP + pstack)

OMP runs pstack (the `pstack@pstack-omp` plugin) as its workflow. Shared rules
live in the Claude Code fragments imported at the bottom; this file adds the
OMP translation, the pstack policy, and OMP's artifact rules.

## OMP harness mapping

- **Skills**: load with `read skill://<name>`. There is no `Skill` tool.
- **Subagent dispatch** → `task`. Inside a pstack skill, follow the skill's
  agent and model choices as the pstack routing rule translates them: when
  the skill names a model (`opus`, `fable`, `sonnet`, `haiku`), every task
  item carries `model: "@<alias>"`. Outside pstack skills: implementers use
  the default `task` agent; code reviewers use `reviewer` (or `refuter` for
  adversarial verification of a finished change); hard root-causing uses
  `debugger`; doc/source fact-finding uses `researcher`; leave `model` unset
  so the configured model roles decide.
- **Task tracking** → `todo`. Do not create a repo `TODO.md`.
- **Claude tool names** in the imported rules map to OMP tools: `Read` →
  `read`, `Edit` → `edit`, `Write` → `write`, `Bash` → `bash`, `Grep` →
  `grep`, `Glob` → `glob`. The "Edit-tool retries" rule applies to a stale or
  mismatched `edit` tag: re-`read` the region, rebuild the edit from the fresh
  snapshot, retry once before escalating.
- **`/code-review`** → spawn the `reviewer` agent.

## pstack policy

These override pstack where they disagree:

- pstack's autonomy ("never block on the human", "just do it") applies to
  reversible local work: edits, commits on a feature branch, local runs,
  subagents.
- **Always ask first** before pushing, force-pushing, opening a PR or MR,
  arming auto-merge, or merging — including inside the babysit, shipping,
  autopilot, and orchestrate playbooks. Prepare the work, then stop and ask.
- pstack decides where its todo files and decision trails go.

## Artifacts

- `.claude/notes/` — point-in-time investigation notes, debugging logs,
  research summaries.
- `.claude/knowledges/` — durable, multi-session findings: hard-won facts,
  protocol gotchas. Promote a note here once it's re-referenced in a later
  session or the lesson generalises beyond one bug.
- Filenames are kebab-case, end in `.md`, lead with the topic. Never put
  these at the repo root or in `docs/` unless the user names that path.
  Create the `.claude/` subdirectory if missing; do not ask.

## Shared rules

@~/.config/claude-code/instructions/branch-names.md

@~/.config/claude-code/instructions/edit-retries.md

@~/.config/claude-code/instructions/subagent-worktrees.md

@~/.config/claude-code/instructions/coding-behavior.md

---

<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
