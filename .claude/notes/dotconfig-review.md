# Dotconfig review — 2026-09-28

Read-only review of all 149 tracked files in `~/.config`. **Nothing has been changed.**
Each batch is a separate commit, but batches share files (`tmux.conf`, `config-installer.sh`, `.gitignore`), so they run in a fixed order: A → B → C → D → rest.
Approve by batch letter (e.g. "do A, B, D").

After approval: a plan goes to `.claude/plans/dotconfig-refactor.md` with per-batch checks (nvim headless first-file open, `zsh -n`, `ghostty +validate-config`, tmux parse, `git config --list`), then one batch at a time with a pause for your review.

Untracking a file does not remove it from git history (applies to `opencode/effort-log.md` and the email).

Legend: **H** high · **M** med · **L** low · ⚠ needs your decision first

---

## Decisions needed before anything runs

| # | Question | Default if you say "go" |
|---|----------|-------------------------|
| D1 | tmux `allow-passthrough on` (`tmux/tmux.conf:94`, added 3e92408 2026-02-16) is live, but memory says it hangs the ocv TUI and must stay off. Re-enabled on purpose? | Turn it off |
| D2 | `.gitconfig:3` global identity is your personal gmail. Your own hook `claude-code/hooks/deny-git-identity-override.sh` (91614e6, 2026-09-10) deliberately enforces that gmail, so this looks intentional. It's already in 1559 public commits, so switching is a preference, not a leak fix. Conflicts with memory `feedback_commit_identity_gh_account` (noreply). If you switch, the hook's 4 messages must change in the same commit. | **Keep gmail**; fix the stale memory instead |
| D3 | tmux `default-terminal $TERM` → `tmux-256color`. Correct per tmux docs, but changes TERM inside every pane. | Change, then test undercurl in nvim |
| D4 | Delete root `AGENTS.md` + `CLAUDE.md` (stale context-mode routing with wrong tool names; the plugin already injects the correct version). | Delete |
| D5 | Delete the 8 vendor-owned opencode skills from disk so oh-my-opencode-slim reinstalls them (they are upstream copies, not your edits). | Untrack + delete |
| D6 | Track `nvim/nvim-pack-lock.json` (currently gitignored) so plugin versions are pinned. | Track it |

---

## A — High-severity bug fixes (~20 min)

- **H** `nvim/lua/plugins/treesitter-config.lua:5` — `event='BufEnter'` loads after the first buffer's FileType fired → `nvim x.py` opens with no TS highlight/folds. Fix: `event={'BufReadPre','BufNewFile'}`. (Bug verified headless; fix still to be tested — zpack has its own event refire.)
- **H** `nvim/lua/plugins/lsp-config.lua:10` — same cause: no LSP on the first file opened. Same fix. (Bug verified headless; fix still to be tested — zpack has its own event refire.)
- **H** `nvim/lua/config/keymaps.lua:171` — marks `prev = '"'` hijacks register selection (`"ayy`, `"+p`). Fix: pick another key.
- **H** `config-installer.sh:4` — bare `aerospace` isn't resolvable → brew aborts the whole install on a fresh machine. Fix: `nikitabobko/tap/aerospace`.
- **M** `config-installer.sh:4` — missing `bun jq`; `.zshrc:61` errors on every shell start without bun; `esp-clangd-update` silently no-ops without jq. Fix: add both, drop unused `wget`.

## B — Superset purge (removed in bbb02b5, 2026-09-19) (~20 min)

- `.superset/config.json` — `git rm`.
- `.claude/knowledges/superset-transparency.md` — delete (move any Paseo-relevant lesson to a paseo note).
- `.claude/knowledges/claude-settings-ownership.md:7-40` — rewrite around the surviving reason (`/config` writes drift settings.json).
- `bin/claude-settings-sync:4,28-33` — stale Superset rationale; narrow `IGNORED_KEYS` so your own hooks get drift-checked.
- `claude-code/.gitignore:53-55` — dead `/skills/superset/` rule; fix backwards comment at `:43`.
- `bin/paseo-repatch:108,204,220,287` — stale Superset comments.
- `config-installer.sh:143,195-199` — links nonexistent `superset/` dir and `bin/superset-repatch`.
- Memory: update "agents via Superset" in `project_herdr_removed.md`.

## C — Remove legacy tools (~25 min)

- **Kitty** (not installed, last touched 2022): `git rm -r kitty/` (15 files) + refs at `.zshrc:204`, `tmux.conf:7,93`, `config-installer.sh:10,143`, `README.md:114`, `zsh-shell-setup.md:136`.
- **OpenAgentsControl leftovers** (removed in dd721ac): `opencode/skills/task-management/`, `opencode/skills/context7/`, `Claude` symlink, `opencode/AGENTS.md:7-23`. Also moots the `router.sh` bugs (set -e silent exit, missing `migrate-schema.ts`, `npx ts-node`).
- **Dead nvim code** (~1,100 lines): `colorscheme/nightfox-config.lua` (706 lines, never required), `colorscheme/flatwhite-config.lua`, `colorscheme-config.lua` (duplicate of `colorscheme/init.lua`), `config/fn-utils.lua` (393 lines, 2 callers → `vim.tbl_extend` / `package.loaded`).
- `.zshrc:195` `rbrew` → nonexistent `/usr/local/bin/brew`.
- `.zprofile:41` `CARAPACE_BRIDGES` lists uninstalled fish/inshellisense → `zsh,bash`.

## D — Untrack vendor/runtime files (~10 min)

- `opencode/skills/{clonedeps,codemap,deepwork,oh-my-opencode-slim,reflect,simplify,verification-planning,worktrees}` ⚠D5
- `opencode/plugins/paseo-terminal-activity.js` — Paseo writes it.
- `opencode/package-lock.json` — already ignored by `opencode/.gitignore:3`, stale.
- `homebrew/trust.json.lock` — 0-byte brew flock file.
- `opencode/effort-log.md` — personal work-hour data in a public repo.
- `opencode/.gitignore:5` ignores itself → rules lost on clone; move them into root `.gitignore`.

## E — nvim behaviour fixes (medium) (~30 min)

- `lsp-config.lua:56` — `automatic_enable=true` starts both `ts_ls` and `vtsls` (+ `omnisharp_mono`). Exclude or uninstall.
- `lsp-config.lua:38` + `blink-cmp-config.lua:7` — redundant capabilities merge; blink capabilities register only on InsertEnter, so early servers miss them.
- `lsp-config.lua:84` — inlay-hint autocmds stack on every LspAttach. Clear per buffer first.
- `after/ftplugin/qf.lua:1-4` — `vim.opt` leaks `nonumber`/`signcolumn=no` globally → `vim.opt_local`.
- `config/keymaps.lua:40` — visual `p` hardcodes `+`, broken over SSH (`clipboard=''`).
- `config/keymaps.lua:78` — buffer-local `gr` shadows builtin `grn/grr/gra…` → timeoutlen wait.
- `config/options.lua:21` — `wildignore` has spaces after commas and `node_module` typo.
- Import-time side effects: `marks-config.lua:37` (autocmd inside `keys`), `llm-config.lua:372` (top-level VimResized), `lsp-config.lua:147` (global diagnostic config in diagflow `init`), `plugins/init.lua:35`, `move-config.lua:1`.

## F — Shell & tmux cleanup (~25 min)

- ⚠D1 `tmux.conf:94` passthrough · ⚠D3 `tmux.conf:8` default-terminal.
- `tmux.powerline.conf` — obsolete "keep status on" block (5-10), duplicate `%hidden`/border/status-style lines, ~65 lines commented-out; rename → `tmux.status.conf`.
- `tmux.conf` — ~50 commented-out lines (iTerm, WT, is_vim, old colors); `Tc/Smulx/Setulc` overrides duplicate `RGB`/`usstyle` features.
- `.zshrc:51` — fnm multishell dirs pile up in PATH on nested shells.
- `.zshrc:34,61` — guard carapace/bun with `(( $+commands[x] ))`.
- `ghostty/config:15` — cursor shape set by both Ghostty and zsh → `shell-integration-features = title`.
- `config-installer.sh:45,75,102,128` — `read` without `-r` (shellcheck SC2162).

## G — git / CLI tools (~20 min)

- ⚠D2 `.gitconfig:3` email · `claude-code/hooks/deny-git-identity-override.sh:32-45` hardcodes the same email 4× → one variable.
- `.gitconfig:5` — `excludesfile=~/.gitignore_global` makes tracked `git/ignore` dead (identical content). Drop the line, delete `~/.gitignore_global`.
- `.gitconfig` — hardcoded `/Users/momeppkt` (5,33) → `~`; `navigate=true` no-op under `--paging=never`; removed `add.interactive.useBuiltin`; duplicate osxkeychain credential; built-in-identical `nvimdiff.cmd`.
- `lazygit/vscode/config.yml` — dead keys, VS Code not installed → delete. `lazygit/config.yml:36` nonexistent `confirm-alt1`; default-valued keys.
- `.gitignore` — prune entries for gone paths (flutter, fish, containers, lazy-lock, carapace, .omc, .weave, opencode-quota…), dedupe `.claude/tmp`, drop `nushell/`.
- `delta/themes.gitconfig` — keep only `[delta "oxocarbon"]`; drop no-op hunk-header sub-styles.
- `bat/config`, `aerospace/aerospace.toml` — stock template comments/defaults.

## H — claude-code settings.json template (~15 min)

- `:111-115` tracked `statusLine` with pinned 0.13.1 path (should be ignored per ownership doc).
- `:69-78` tracked vendor-injected context-mode SessionStart hook.
- `:25-26` curl-localhost allows can never fire (deny `curl http*` wins).
- `:30-36` redundant under `mcp__codegraph__*`; `:127-131` duplicate effortLevel; `:27,29` playwright/supabase perms for disabled plugins (confirm).

## I — Scripts (~15 min)

- `bin/paseo-repatch` — `str | None` crashes on `/usr/bin/python3` 3.9 (add `from __future__ import annotations`); `--quiet` doesn't silence notes; stamp written before MISSED check.
- `bin/claude-relink:11` — `set -e` + failing `readlink` exits before the message prints.

## J — Docs drift (~20 min)

- `README.md:106` wrong tmux keys table; `:97` "tmp"→"tpm"; no Ghostty/starship section.
- `claude-code/CLAUDE.md:231-240`, `opencode/AGENTS.md:25-43,129-138` — tool-injected CODEGRAPH blocks + competing "prefer LSP" search order.
- `zsh-shell-setup.md:33,115-132` compinit and brew-wrapper drift; nushell mentions in comments.
- `zig-015-macos27-sdk.md:77` — `zig@0.15` still installed; note says it can go.
- nvim trivia: typos (`max_attemps`, `bufdetele`), `after/lsp/*` empty stubs used as hidden ensure_installed list, packer `use` global, lualine dead conditions, ~15 commented-out blocks.

---

**Not checked:** live `~/.claude/settings.json` vs the tracked template (the classifier blocked the read); staleness of `.claude/knowledges/nvim-nightly-bufload-modified-regression.md` and `tmux-agent-dock.md`.

**Clean, no action:** starship, eza, gh-dash, aerospace-swipe, paseo oxocarbon plugin, esp-clangd-update, Ghostty keybindings (no tmux overlap), model IDs, no secrets beyond the email.
