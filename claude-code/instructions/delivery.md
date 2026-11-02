## Delivering a change

Every change headed for a PR or MR goes through these steps, whether one
agent does the work or a coordinator runs several:

1. Commit after each item, one commit per item. Long runs can end on a
   budget or rate limit; committed work survives that.
2. Prove it on the real artifact: run it and exercise the changed path.
3. The cleanup gate (pstack policy). Its passes must not change behavior:
   prove that as below, or redo step 2.
4. If the change is visible, the user checks it on the device or UI.
5. Ask, then push or open the PR or MR, unless the change qualifies for
   the no-ask path (pstack policy).
6. Merge only on the user's word, or through the no-ask path.

A review verdict of FIX means new commits, then a re-review of only the fix
range.

- **Prove that "no behavior change" is true.** Compiling is not proof for
  refactors, deslop, comment passes or optimizations. Show identical output:
  identical test output, byte- or pixel-identical renders, and an identical
  binary where the build is reproducible. Measure performance before and
  after with the same harness, and report the numbers with the method.
- **Shared formats.** Changing anything other code reads (a wire or file
  format, an API field, a config key, a register) means listing every reader
  in every repo and changing them together. Another repo's side is its own
  PR or MR; make it a draft if someone else owns that repo.
- **User decisions.**
  - Present each choice as a short table: what changes for users, the risk,
    and a recommendation.
  - Risky items stay the user's call even after "do all": security and
    auth, persisted data and migrations, public APIs and wire formats,
    release, deploy and boot paths.
  - An agent whose fix would settle an open user question stops and reports
    instead of fixing.
  - A "skip" cancels that work and removes its scratch files and worktree.
- **Record every decision** when it is made, whoever made it: the date, the
  choice, why, and the alternatives turned down. Use the project's run notes
  if it keeps them (for example a notes branch); otherwise
  `.claude/notes/<topic>.md` in the current worktree, created if missing.
  Check merge and PR state against the forge before recording it. Commit
  the notes with the work; pushing them follows the push rule.
- **Reports to the user.**
  - Plain words and short tables, with what changed for users first.
  - Before-and-after numbers, and what is untested.
  - Questions numbered at the end.

## Coordinated work

When a session runs work through subagents, the main agent coordinates and
the subagents do the work.

- **Roles.**
  - **Coordinator:** plans, dispatches, reads reports, integrates, talks to
    the user, and runs every review and comment-sicko pass itself, so no
    agent reviews its own work.
  - **Subagents:** implement, review, audit and benchmark.
  - Keep one long-lived agent per thread (implementer, bench, notes keeper)
    and send it follow-ups instead of spawning a new one. When its context
    is near full, start a fresh agent from its handoff file.
  - A notes-keeper agent, when there is one, keeps the decision record.
  - Subagents may not see these instructions (OMP subagents get none of
    them). Each brief states the rules that bind it: the absolute worktree
    path, one commit per item, no push, and which gate steps it runs.
- **One writer per worktree.**
  - Read-only reviewers and auditors get their own detached checkout of the
    commit under review.
  - Parallel implementers on files that don't overlap work in their own
    scratch worktrees and hand back commits or patches. The coordinator
    integrates them once the main tree's writer is done.
- **Shared locks** guard builds and devices. Take one with
  `mkdir /tmp/<repo>-<resource>.lock`, then write an `owner` file inside
  naming the agent, worktree, task and start time; remove the directory
  when done. A lock whose agent is no longer running is stale: confirm that
  before removing it, and never remove a live agent's lock.
- **After a failed agent**, check its worktree, the locks and any device
  state, then resume the same agent with a message.
- **Post-merge sweep**, only when the user asks. On a new branch (named per
  the branch-names rule) off the integration branch, covering the merges
  since the last sweep or the range the user names:
  1. In parallel, read-only: a bug hunt (`/code-review`, high effort) and a
     performance audit ranked by what users notice.
  2. Fix the bugs found in the swept range and the performance items the
     user accepts, one commit each. Bugs older than the swept range are
     listed for the user, not fixed.
  3. The cleanup gate over the whole sweep branch.
