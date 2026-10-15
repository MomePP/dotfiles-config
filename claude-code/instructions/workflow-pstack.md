## Workflow → pstack

Claude Code runs pstack (the `pstack@pstack-claude` plugin) as its workflow.
Pick the skill, playbook, or principle the way pstack routes it; when unsure
which fits, `/poteto-help` answers that.

## pstack policy

These override pstack where they disagree:

- pstack's autonomy ("never block on the human", "just do it") applies to
  reversible local work: edits, commits on a feature branch, local runs,
  subagents.
- **Always ask first** before pushing, force-pushing, opening a PR or MR,
  arming auto-merge, or merging — including inside the babysit, shipping,
  autopilot, and orchestrate playbooks. Prepare the work, then stop and ask.
- pstack decides where its todo files and decision trails go.
