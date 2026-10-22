## Artifacts

- `.claude/notes/` — point-in-time investigation notes, debugging logs,
  research summaries.
- `.claude/knowledges/` — durable, multi-session findings: hard-won facts,
  protocol gotchas. Promote a note here once it's re-referenced in a later
  session or the lesson generalises beyond one bug.
- Filenames are kebab-case, end in `.md`, lead with the topic. Never put
  these at the repo root or in `docs/` unless the user names that path.
  Create the `.claude/` subdirectory if missing; do not ask.

## Scratch files → placed by scope

Pick the location by who needs the file and for how long:

| Scope | Where | Examples |
|---|---|---|
| This worktree, disposable | `.claude/tmp/` | build logs, serial captures, panic dumps, redirected output |
| This worktree, rerun during the current work | `.claude/test/` | hardware test scripts, host harnesses, probe and measurement scripts |
| Shared across worktrees, sessions or agents | `/tmp` | build and board locks, handoff files between checkouts |
| Needed after this work ends, or by other worktrees | commit it (`test/`, `scripts/`) | a harness a knowledge file depends on |

- Paths are relative to the checkout you are working in, so each worktree
  keeps its own `.claude/tmp/` and `.claude/test/`.
- Both are ignored globally (`~/.config/git/ignore`); never commit them.
  Create them if missing; do not ask.
- A `.claude/knowledges/` file must not depend on a `.claude/tmp/` or
  `.claude/test/` path: that file is gone in every other checkout. Commit the
  script first, or describe the check in the knowledge file itself.
- When the work lands, delete the worktree's `.claude/tmp/` and
  `.claude/test/` with it.
