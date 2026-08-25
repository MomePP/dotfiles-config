# ~/.claude/settings.json is not ours to symlink

`config-installer.sh` symlinks `claude-code/settings.json` to
`~/.claude/settings.json`, which is right for provisioning a fresh machine and
wrong for keeping it linked afterwards.

**Superset rewrites that file in place every time the app starts**, replacing
the symlink with a plain file. Claude Code writes to it too — `/config` changes
land there. Re-linking only resets a countdown to the next Superset restart.

Tested twice in August 2026, because the first result had an obvious
alternative explanation:

1. Symlinked to a repo copy with **no** Superset hooks, restarted → plain file,
   hooks restored. Consistent with "it writes when its hooks are missing".
2. So the hooks were tracked in the repo copy, making live and repo
   byte-identical, and it was symlinked and restarted again → **still replaced
   with a plain file**, even with nothing to add.

The write is unconditional. Tracking the vendor hooks buys nothing, so it was
reverted and they stay untracked for the original reason.

Worth noting the app rewrites on *its* start, not the host service's — the
`terminal-host.pid` mtime was unchanged across the second test while
`settings.json` picked up a fresh timestamp.

## What survives a Superset rewrite

Superset preserves the file's existing content and adds only its own hook
entries — `theme`, `statusLine`, `permissions`, `enabledPlugins` all came
through untouched. So the live file is safe to edit by hand; it just will not
stay a symlink.

## Treat the repo copy as a template, not a mirror

`claude-code/settings.json` is what a new machine starts from. It should carry
deliberate settings and **not** vendor-injected hooks:

- Superset's 8 `notify.sh` hooks (`SessionStart`, `UserPromptSubmit`,
  `SessionEnd`, `Stop`, `StopFailure`, `PostToolUse`, `PostToolUseFailure`,
  `PermissionRequest`) re-register themselves on app start.
- `context-mode-cache-heal.mjs` and `herdr-agent-state.sh` likewise.

Tracking those would mirror vendor output into the repo on every update, which
is the reason the installer already documents not doing it.

To port a deliberate change from live into the repo, diff the two by key —
comparing file sizes is misleading, since the hooks block alone accounts for
most of the difference:

```bash
python3 -c "
import json
live=json.load(open('$HOME/.claude/settings.json'))
repo=json.load(open('claude-code/settings.json'))
print([k for k in set(live)|set(repo) if live.get(k)!=repo.get(k)])"
```

## Watch out for

If the symlink *is* in place when Claude Code writes settings, the write goes
straight into the dotfiles repo and shows up as uncommitted drift. That is how
`remoteControlAtStartup` appeared as a repo change without anyone editing it.
