# Global instructions (OMP + pstack)

OMP runs pstack (the `pstack@pstack-omp` plugin) as its workflow. Shared rules
live in the Claude Code fragments imported at the bottom; this file adds only
the OMP translation. OMP subagents receive none of this file, imports
included.

## OMP harness mapping

- **Skills**: load with `read skill://<name>`. There is no `Skill` tool.
- **Subagent dispatch** → `task`. Inside a pstack skill, follow the skill's
  agent and model choices as `rule://pstack-omp-tools` maps them: `task` has
  no per-item `model` field, so a named model (`opus`, `fable`, `sonnet`,
  `haiku`) selects a model-pinned agent (`task-<alias>`, `poteto-<alias>`).
  Outside pstack skills: implementers use the default `task` agent; code
  reviewers use `reviewer` (or `refuter` for adversarial verification of a
  finished change); hard root-causing uses `debugger`; doc/source
  fact-finding uses `researcher`; their models come from `modelRoles`.
- **Task tracking** → `todo`. Do not create a repo `TODO.md`.
- **Claude tool names** in the imported rules map to OMP tools: `Read` →
  `read`, `Edit` → `edit`, `Write` → `write`, `Bash` → `bash`, `Grep` →
  `grep`, `Glob` → `glob`. The "Edit-tool retries" rule applies to a stale or
  mismatched `edit` tag: re-`read` the region, rebuild the edit from the fresh
  snapshot, retry once before escalating.
- **`/code-review`** → spawn the `reviewer` agent.

## Shared rules

@~/.config/claude-code/instructions/pstack-policy.md

@~/.config/claude-code/instructions/artifacts.md

@~/.config/claude-code/instructions/branch-names.md

@~/.config/claude-code/instructions/edit-retries.md

@~/.config/claude-code/instructions/subagent-worktrees.md

@~/.config/claude-code/instructions/coding-behavior.md

@~/.config/claude-code/instructions/context-handoff.md

@~/.config/claude-code/instructions/delivery.md

@~/.config/claude-code/instructions/hardware.md

@~/.config/claude-code/instructions/ci-minutes.md