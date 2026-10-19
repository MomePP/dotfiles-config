---
name: gogo-mr-pipeline
description: Turns one confirmed GoGoBoard finding into an opened MR. Steps are a worktree, the fix, the build, board before/after, an independent review, a fix round, then push and open with an evidence-labelled description. Use for any GoGoBoard fix or feature MR in gogo-firmware, gogo-code or the LILCMU GitHub co-MCU repos.
user-invocable: true
---

# GoGo MR pipeline

One concern per branch. Each MR must be reviewable without the conversation that produced it.

## 1. Branch

- **Prefix from git-flow config.** Run `git config --get-regexp '^gitflow\.'`. Use `bugfix/` for repairs and `feature/` for new capability. Set `git config gitflow.branch.<b>.base develop`.
- **Worktree.** Create it with `git -C <a scratch worktree> worktree add -b <branch> <session dir>/<short> origin/develop`, then run `git submodule update --init --recursive`. GitHub repos (LILCMU) get a fresh clone instead.
- **Stacked work.** Base it on the parent MR branch, open it against that branch, and say so in the description.

## 2. Worker brief (must include)

- **Location.** The worktree's absolute path, plus the checkouts the worker must not touch.
- **The finding.** Its report path, with the instruction to re-verify the cause in code before fixing.
- **Rules.** The project's `CLAUDE.md` rules:
  - no magic numbers;
  - knowledge files updated in the same commit;
  - packet formats in the `gogo-uart.h` registry;
  - cross-task rules (volatile, fill before flag, memw);
  - conventional commits;
  - comments only for a non-obvious why.
- **Build.** `pio run -e release` and `pio run -e debug`, with release RAM and flash compared to develop. Retry when the esptool install times out during parallel builds.
- **Board proof.** Before and after on the board with the same script (see `gogo-board-test`). If the board cannot show it, say so and name what proves it instead.
- **Decisions.** For an owner product choice, take the conservative default and emit `DECISION: question | default | blocks | link`.
- **Delivery.** One commit, not pushed. The report gives the commit, diff summary, sizes, verbatim board output, what is not verified, and an MR description draft.

## 3. Review

- **Reviewer.** Every commit gets a read-only `reviewer`, never the author. The reviewer:
  - reads the diff, every caller and the cross-task paths;
  - checks the board evidence really proves the claim;
  - runs `git merge-tree` against conflicting open MRs;
  - returns MERGE, FIX (with file:line) or REJECT.
- **On FIX.** Hand the consolidated brief to a fresh worker, who amends into one commit. Re-review whenever the code grew. Small doc or wording findings can be applied by the coordinator directly.
- **Existing open MR.** Add a new commit rather than amending, push, and post an MR note explaining it.

## 4. Open

- Push, then `glab mr create` against `develop`. GitHub repos get `gh pr create --draft`.
- **Description:**
  - **Problem**: what a child or teacher sees.
  - **Cause**: the file:line chain.
  - **Fix**: what changed.
  - **Evidence**: each item labelled measured on the board, host test, or code only.
  - **Not tested.**
  - **Merge notes**: order, conflicts, stacked base, and for compiler MRs "merging redeploys production".
- **Cross-MR effects.** When one MR changes another, for example deleting a function that a newer MR now calls, post a note on the other MR.
- **Never merge.** The owner merges.

## 5. After opening

- **Trail.** Log the MR in the decision trail and add it to `mr-decision-guide.md` (see `gogo-notes`).
- **State.** Read MR state from the API, never from memory.
