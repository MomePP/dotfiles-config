## pstack policy

These override pstack where they disagree:

- pstack's autonomy ("never block on the human", "just do it") covers the
  whole road up to the merge: edits, commits, pushing, force-pushing the
  work's own branch, opening a PR or MR, fixing CI, including inside the
  babysit, shipping, autopilot, and orchestrate playbooks. Do it, then
  report it.
- **Merging waits for the user.** Never merge or arm auto-merge on your
  own; pushing straight to the integration, release or hotfix branch counts
  as merging. Bring the PR or MR to ready (cleanup gate done, review said
  SHIP, CI green), report in the session what changed and how to check it,
  then stop until the user says merge.
- pstack decides where its todo files and decision trails go.
- **Cleanup gate before every PR or MR.** pstack's playbooks name `/deslop`
  before commit and `/no-comments` before review, but they get skipped. Treat
  both as required, in this order, before opening a PR or MR (draft
  included) and before pushing new work to an open one:
  1. `/deslop`, as its own commit;
  2. `/no-comments` (comment-sicko), its accepted edits and reshapes as their
     own commit;
  3. a `/code-review` pass on the result; then the build and tests.

  Scope: the whole branch diff against its target before the PR or MR
  opens; for a later push, only the commits since the last gated push.
  Pushed commits are never rewritten for this; the passes are new commits.
  A subagent that prepares a PR runs steps 1–2 and the build; its
  coordinator runs step 3. Say in the PR or MR description that both passes
  ran, or why one was skipped (for example, a docs-only change). A pass that
  finds nothing is still reported as run.
