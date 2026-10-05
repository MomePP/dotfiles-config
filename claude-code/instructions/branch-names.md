## Branch names → read git-flow config, don't copy nearby branches

Before creating a branch, check whether the repo has git-flow initialised:

```bash
git config --get-regexp '^gitflow\.'
```

If it returns anything, **its prefixes are the convention** — typically
`feature/`, `bugfix/`, `release/`, `hotfix/`, `support/`, with
`gitflow.branch.master` and `gitflow.branch.develop` naming the two long-lived
branches. Use them, and record the base the way the repo already does:

```bash
git config gitflow.branch.<full-branch-name>.base develop   # hotfix/* uses master
```

Do **not** infer the prefix by pattern-matching branches in `git branch -a`.
A repo can accumulate one-off branches that violate its own convention
(e.g. a stray `fix/…` alongside four conforming `bugfix/…`), and copying the
outlier silently spreads it. The config is authoritative; the branch list is not.

Choosing between prefixes: `feature/` adds capability, `bugfix/` repairs
behaviour on `develop`, `hotfix/` repairs a release and branches from `master`.
When work is genuinely mixed, pick by what the merge is *for* and say which
you chose, so the user can redirect cheaply — renaming an unpushed or
freshly-pushed branch is trivial, renaming one with an open MR is not.
