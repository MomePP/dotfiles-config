# ~/.claude/settings.json is a template, not a mirror

`config-installer.sh` symlinks `claude-code/settings.json` to
`~/.claude/settings.json`, which is right for provisioning a fresh machine and
wrong for keeping it linked afterwards.

Several writers touch the live file: Claude Code itself (every `/config`
change), and tools that register their own hooks in it — context-mode, Paseo,
termio. The live file ends up a plain file, not a link. And while a link *is*
in place, those writes land straight in this repo as uncommitted drift. That
is how `remoteControlAtStartup` once appeared as a repo change without anyone
editing it.

## What the tracked copy carries

`claude-code/settings.json` is what a new machine starts from. It carries
deliberate settings and your own hooks (`deny-git-identity-override.sh`,
`codegraph prompt-hook`), and **not**:

- `statusLine` — claude-hud writes it with a version-stamped plugin-cache path
  (`claude-settings-sync`'s `IGNORED_KEYS`).
- Vendor hooks — each tool re-registers its own on install/start, so they
  self-heal on a fresh machine. `claude-settings-sync` drops any hook whose
  command matches `VENDOR_HOOK_MARKERS` from both sides before comparing:
  `context-mode-cache-heal.mjs`, `PASEO_HOOK_CLI` (Paseo agent status),
  `termiod` (termio session status). A new tool that injects hooks shows up as
  `hooks` drift until its marker is added there.

## Porting a deliberate change

Run `claude-settings-sync` — it reports drift by key, exits 1 when there is
any. `--write` ports live into the repo copy (vendor hooks stripped, key order
kept) and stages it for review; it never commits. `--all` includes
`IGNORED_KEYS`.

## claude-hud's config must be copied, never symlinked

`~/.claude/plugins/claude-hud/config.json` is tracked at
`claude-code/claude-hud/config.json` and installed with `copy_config`, not
`symlink_config`.

Since upstream 0.8.0 the plugin's loader hardens config input — `readConfigFile`
lstats the path and bails on anything that is not a regular file
(`src/config.ts:1254`). A symlink is therefore **silently ignored** and the HUD
falls back to stock defaults: pipes project style, block bars, percent context.
No warning, no error; it just stops looking like yours. Verified 2026-08-26 by
linking it and watching the HUD render as `[Opus 5 (1M context)]` with default
bars.

Nothing else writes that file — unlike `settings.json`, no vendor rewrites it —
so a copy only drifts when you change it deliberately.

The file sits at `plugins/claude-hud/`, a sibling of `plugins/cache/`, so it
survives plugin updates untouched. Only the `statusLine` path in
`settings.json` is version-stamped, and that stays untracked for the reason
recorded in `claude-settings-sync`'s `IGNORED_KEYS`.
