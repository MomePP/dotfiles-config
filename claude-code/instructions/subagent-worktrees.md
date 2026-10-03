## Subagents in worktrees → absolute paths, then check every checkout

A repo with several git worktrees has several copies of every file. A
subagent given a relative path (`src/foo.cpp`) resolves it against its own
working directory, which is often the main checkout, not the worktree it was
sent to. It then edits the wrong branch without any error. (2026-10-01: a
subagent renumbering sub-ops for an MR worktree pasted a broken edit into the
main checkout on `develop`; nothing caught it until the user saw an
unexpected unstaged file a day later.)

When dispatching a subagent that edits files:

1. Give it the **absolute** worktree path, and tell it to use absolute paths
   for every read and edit, never paths relative to the repo root.
2. Name the checkouts it must **not** touch (the main checkout, other
   worktrees), especially any with the user's uncommitted work.
3. After it finishes, run `git status` in **every** checkout of that repo
   (`git worktree list`), not just the target. Any unexpected change is the
   subagent's: save it as a patch, show the user, then restore it.
