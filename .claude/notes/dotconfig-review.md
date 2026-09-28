# Dotconfig review — open findings

Tracker for the 2026-09-28 review of `~/.config`. Batches A, B, C and D3 shipped
on `bugfix/dotconfig-review`; everything below is **not yet approved**. Line
numbers are from the review and may have drifted — re-check before editing.

Untracking a file does not remove it from git history.

## Open decisions

| # | Question | Default |
|---|----------|---------|
| D4 | Delete root `AGENTS.md` + `CLAUDE.md` (stale context-mode routing with opencode-style tool names; the plugin injects the correct version). | Delete |
| D5 | Delete the 8 vendor-owned opencode skills (`clonedeps codemap deepwork oh-my-opencode-slim reflect simplify verification-planning worktrees`) from disk so oh-my-opencode-slim reinstalls them. | Untrack + delete |
| D6 | Track `nvim/nvim-pack-lock.json` (gitignored) so plugin versions are pinned. | Track it |

Settled, don't re-raise: tmux `allow-passthrough on` stays (no ocv); `.gitconfig`
gmail identity stays; nvim `'`/`"` are marks.nvim by design.

## D — Untrack vendor/runtime files

- `opencode/skills/{…8 above}` (⚠D5), `opencode/plugins/paseo-terminal-activity.js` (Paseo writes it), `opencode/package-lock.json` (already ignored, stale), `homebrew/trust.json.lock` (brew flock), `opencode/effort-log.md` (personal work hours, public repo).
- `opencode/.gitignore` ignores itself → move its rules into the root `.gitignore`.

## E — nvim behaviour (medium)

- `lsp-config.lua` `automatic_enable=true` starts both `ts_ls` and `vtsls` (+ `omnisharp_mono`).
- `lsp-config.lua` redundant capabilities merge; blink registers capabilities only on InsertEnter, so early servers miss them.
- `lsp-config.lua` inlay-hint autocmds stack on every LspAttach — clear per buffer first.
- `after/ftplugin/qf.lua` `vim.opt` leaks `nonumber`/`signcolumn=no` globally → `vim.opt_local`.
- `config/keymaps.lua` visual `p` hardcodes `+` (broken over SSH, `clipboard=''`); buffer-local `gr` shadows `grn/grr/gra…`; `w*` focus maps delay `w`.
- `config/options.lua` `wildignore` has spaces after commas and `node_module` typo.
- Import-time side effects: `marks-config.lua` autocmd inside `keys`, `llm-config.lua` top-level VimResized, `lsp-config.lua` global diagnostic config in diagflow `init`.
- Treesitter doesn't start for buffers that never read a file (`nvim -`, `:enew` + `:set ft`).
- Comment `sessions-config.lua:30`: `nested = true` is what lets TS/LSP attach to restored buffers.
- `plugins/colorscheme/oxocarbon-config.lua` → `init.lua` split now selects between one theme; merge. `colorscheme/colorset.lua` `M.lualine` is dead.

## F — Shell & tmux cleanup

- `tmux.powerline.conf`: obsolete "keep status on" block, duplicate `%hidden`/border/status-style lines, ~65 commented lines; rename → `tmux.status.conf`.
- `tmux.conf`: ~50 commented lines (iTerm, WT, is_vim, old colours); `Tc/Smulx/Setulc` overrides duplicate `RGB`/`usstyle` features.
- `.zshrc`: fnm multishell dirs pile up in PATH on nested shells; guard carapace/bun with `(( $+commands[x] ))`.
- `ghostty/config:15` cursor shape set by both Ghostty and zsh → `shell-integration-features = title`.
- `config-installer.sh` `read` without `-r` (SC2162); `paseo` missing from `config_dirs`; `font-maple-mono-nf` not installed.

## G — git / CLI tools

- `.gitconfig`: `excludesfile=~/.gitignore_global` makes tracked `git/ignore` dead; hardcoded `/Users/momeppkt`; `navigate=true` no-op under `--paging=never`; removed `add.interactive.useBuiltin`; duplicate osxkeychain; built-in-identical `nvimdiff.cmd`.
- `claude-code/hooks/deny-git-identity-override.sh` repeats the email 4× → one variable.
- `lazygit/vscode/config.yml` dead (VS Code not installed); `lazygit/config.yml` nonexistent `confirm-alt1` + default-valued keys.
- `.gitignore`: entries for gone paths (flutter, fish, containers, lazy-lock, carapace, .omc, .weave, opencode-quota…), duplicate `.claude/tmp`, `nushell/`.
- `delta/themes.gitconfig` keep only `[delta "oxocarbon"]`; `bat/config`, `aerospace/aerospace.toml` stock comments/defaults; `homebrew/trust.json` redundant tap-covered entries (`brew untrust`).

## H — claude-code `settings.json` template

- Tracked `statusLine` with pinned claude-hud path (should be untracked).
- curl-localhost allows can never fire (deny `curl http*` wins); codegraph perms redundant under `mcp__codegraph__*`; duplicate opus `effortLevel`; playwright/supabase perms for disabled plugins (confirm).

## I — Scripts

- `bin/paseo-repatch`: `str | None` crashes on `/usr/bin/python3` 3.9; `--quiet` doesn't silence notes; stamp written before the MISSED check.
- `bin/claude-relink`: `set -e` + failing `readlink` exits before its message.
- `bin/claude-settings-sync`: `strip_vendor_hooks` crashes on `"command": null`; `--write` re-adds `hooks` at the end when repo had none.

## J — Docs drift

- `README.md` wrong tmux keys table, "tmp"→"tpm", no Ghostty/starship section.
- `claude-code/CLAUDE.md`, `opencode/AGENTS.md`: tool-injected CODEGRAPH blocks + competing "prefer LSP" search order.
- `zsh-shell-setup.md` compinit and brew-wrapper drift; nushell mentions in comments.
- `zig-015-macos27-sdk.md`: `zig@0.15` still installed though the note says it can go.
- nvim trivia: `max_attemps`/`bufdetele` typos, `after/lsp/*` empty stubs as hidden ensure_installed, packer `use` global, lualine dead conditions, ~15 commented blocks.
