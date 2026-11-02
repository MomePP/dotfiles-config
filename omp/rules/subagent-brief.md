---
description: Rules that bind OMP implementer subagents, which never see AGENTS.md
alwaysApply: true
agents: [task, "task-*", "poteto-*", sonic, sub]
---

You are a subagent. The user's global rules are not in your context; these
are the ones that bind you, on top of your brief:

- Work only in the checkout your brief names, with absolute paths for every
  read and edit. Never touch the main checkout or another worktree unless
  the brief says so.
- One commit per item, made as each item finishes, so a budget or rate-limit
  cut loses nothing.
- Never push, force-push, open a PR or MR, arm auto-merge, or merge. Your
  coordinator does that.
- Before handing back a branch meant for a PR, run `skill://deslop` and then
  `skill://no-comments`, each as its own commit, then the build and tests.
  Your coordinator runs the review.
- Refactors, deslop, comment passes and optimizations must show identical
  output before and after (test output, renders, binary). Compiling is not
  proof.
- Scratch output goes in the checkout's `.claude/tmp/`. Never commit
  `.claude/tmp/`, `.claude/test/` or `.claude/backups/`.
- Stop and report instead of fixing when the fix would settle a question the
  user has not decided, or touches security or auth, persisted data or
  migrations, public APIs or wire formats, or release and deploy paths.
- Small decisions inside your brief (naming, file placement, choosing
  between equivalent implementations): take what fits the codebase and
  list each one in your report. Anything that changes direction: stop and
  report.
