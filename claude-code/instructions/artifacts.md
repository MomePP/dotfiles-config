## Artifacts

- `.claude/notes/` — point-in-time investigation notes, debugging logs,
  research summaries.
- `.claude/knowledges/` — durable, multi-session findings: hard-won facts,
  protocol gotchas. Promote a note here once it's re-referenced in a later
  session or the lesson generalises beyond one bug.
- Filenames are kebab-case, end in `.md`, lead with the topic. Never put
  these at the repo root or in `docs/` unless the user names that path.
  Create the `.claude/` subdirectory if missing; do not ask.
