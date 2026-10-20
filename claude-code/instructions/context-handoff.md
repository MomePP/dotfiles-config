## Context window → write a handoff before it fills

When the context window passes about 75% full, stop starting new work and
write a handoff document first, so nothing in progress is lost if the session
is compacted, cut off or resumed by someone else.

Where:

- If the project keeps run notes (for example `.claude/notes/` on a notes
  branch), put it there as `handoff-<YYYY-MM-DD>.md`, commit and push it.
- Otherwise put it in `.claude/notes/handoff-<YYYY-MM-DD>.md` in the current
  worktree (see the artifacts rules) and commit it.

What it must hold, so a fresh session can continue without the transcript:

1. Where the source of truth lives (decision log, MR list, notes) and the
   commit that holds the latest version.
2. The binding rules for this work (locks, checkouts not to touch, review
   and push rules, owner decisions already taken).
3. Hardware or environment state as last seen (ports, what is flashed,
   locks held).
4. Every agent or job still running: name, task, repo/branch/worktree, and
   what to do with its result (review it, push it, post a note).
5. Every result waiting on a review verdict, and the exact next step after
   SHIP or FIX.
6. Work decided but not started, and what each item waits on.
7. What the final reply to the user must cover, including disclosures.

Then keep working. Update the same file instead of writing a second one if
the window fills again later. A session harness may compact automatically;
the handoff is what survives it, so write it before, not after.
