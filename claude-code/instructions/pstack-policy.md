## pstack policy

These override pstack where they disagree:

- pstack's autonomy ("never block on the human", "just do it") applies to
  reversible local work: edits, commits on a feature branch, local runs,
  subagents.
- **Always ask first** before pushing, force-pushing, opening a PR or MR,
  arming auto-merge, or merging — including inside the babysit, shipping,
  autopilot, and orchestrate playbooks. Prepare the work, then stop and ask.
  The one exception is the no-ask path below; force-pushing always asks.
- **No-ask path.** Push, open, merge and report without asking only when
  all of these hold; if any is in doubt, ask:
  - **Proven:** delivery steps 1–3 are done, the gate's review said SHIP,
    and CI is green.
  - **Nothing breaks:** nothing other code reads changes (shared formats),
    no risky item from the user-decisions list, and no change a user would
    notice that needs their check (delivery step 4).
  - **No downside:** the user owns the repo, the target is the integration
    branch (never a release, production or hotfix branch), and merging
    triggers no deploy, release, data change or cost.

  Then, in order:
  1. Push and open the PR or MR, saying it took the no-ask path and why.
  2. Wait for CI and any review bots; treat their findings like a review.
  3. Merge the way the repo merges.
  4. Check the target branch: update it, then build, test and smoke the
     merged head, and `/code-review` the merged change.
  5. Record the merge and the checks in the notes (record every decision).
  6. Tell the user: PR link, what changed for users, the checks run.

  If step 4 finds a problem, stop: open a revert PR or MR without merging
  it and tell the user at once.
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
