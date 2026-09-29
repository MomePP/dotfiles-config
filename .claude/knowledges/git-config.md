# git config

`~/.gitconfig` is a symlink to the repo's `.gitconfig`.

- **Identity** is `momeppkt <peeranut32@gmail.com>`, deliberately, although the
  repo is public. `claude-code/hooks/deny-git-identity-override.sh` refuses
  every way an agent could override it (`git -c user.*`, `GIT_AUTHOR_*`,
  `git config user.*` writes). The hook blocks any Bash command whose *text*
  contains such a write, test commands included — feed test JSON from a file.
- **Global ignore** is git's XDG default, `~/.config/git/ignore` (tracked as
  `git/ignore`). Don't set `core.excludesfile`: it shadows that file.
- **Credentials**: `osxkeychain` comes from brew's system gitconfig
  (`/opt/homebrew/etc/gitconfig`); `.gitconfig` only adds per-host `gh` /
  `glab` helpers, each preceded by an empty `helper =` to reset the list.
- **Pager** is `delta --paging=never` with the `oxocarbon` feature from
  `delta/themes.gitconfig` (the only feature kept there). `navigate` needs a
  pager, so it isn't set. `diff.tool = nvimdiff` uses git's built-in command.
