## CI minutes → skip CI on work-in-progress pushes

The LILCMU GitLab group shares 400 shared-runner compute minutes a month.
gogo-code builds on every push to every branch (about 5 minutes each);
gogo-firmware builds only on its release branches and tags (about 9 minutes
each). In the first week of November 2026, branch pushes used 90% of the
month.

- Push work in progress to a `feature/*`, `bugfix/*` or `wip/*` branch with
  `git push -o ci.skip`, and use it for every push that only changes docs,
  notes or comments. GitLab records the pipeline as skipped and uses no
  minutes.
- Push without `-o ci.skip` once, when the branch is ready for review or
  merge, so the MR shows one build of its final head. Build locally before
  that push. A docs-only branch never needs that build.
- Push once per review round, not once per commit.
- Never push the same commit to a second branch to keep a copy: each branch
  builds it again.
- Never use `-o ci.skip` on an integration or release branch (`develop`,
  `master`, `dev-release`, `preview-release`) or on a tag: those builds
  publish. Push only real changes there; docs-only or CI-script edits wait
  for the next real change.
- GitHub ignores `-o ci.skip`; this rule is for GitLab remotes.
