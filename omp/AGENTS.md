# Global instructions (OMP)

Shared rules live in the Claude Code file imported below; this file only adds
the OMP-specific translation. Where the two disagree on tool names, this file
wins.

## OMP harness mapping

- **Skills**: a `superpowers:<name>` reference means the Superpowers skill
  `<name>`; load it with `read skill://<name>` (e.g. `skill://brainstorming`).
  There is no `Skill` tool.
- **Ignore the "Pi tool mapping" block** injected by the Superpowers bootstrap.
  OMP is not stock Pi: it has subagents and a task list.
  - Subagent dispatch → `task`. Implementers use the default `task` agent;
    spec/code-quality reviewers use `reviewer` (or `refuter` for adversarial
    verification of a finished change); hard root-causing uses `debugger`;
    doc/source fact-finding uses `researcher`. Do not pin models — the
    configured model roles decide.
  - `TodoWrite` / task tracking → `todo`. Do not create a repo `TODO.md`.
- **Claude tool names** in the imported rules map to OMP tools: `Read` →
  `read`, `Edit` → `edit`, `Write` → `write`, `Bash` → `bash`, `Grep` →
  `grep`, `Glob` → `glob`. The "Edit-tool retries" rule applies to a stale or
  mismatched `edit` tag: re-`read` the region, rebuild the edit from the fresh
  snapshot, retry once before escalating.
- **`/code-review`** → spawn the `reviewer` agent.
- **Artifacts** still go under the project's `.claude/` directory
  (specs/plans/notes/knowledges) so Claude Code and OMP share them.

## Shared rules

@~/.config/claude-code/CLAUDE.md
