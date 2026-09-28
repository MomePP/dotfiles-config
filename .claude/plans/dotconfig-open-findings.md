# Dotconfig Open Findings (batches D–J, decisions D4–D6) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clear every remaining finding in the review tracker and push the commits to PR #13.

**Architecture:** Config edits on `bugfix/dotconfig-review`, working in the live `~/.config`. One commit per task. Each task has a headless check that fails before the change and passes after it. Nothing touches the user's running tmux server.

**Tech Stack:** Neovim nightly + zpack, zsh, tmux 3.7c, Ghostty tip, git/delta/lazygit, Homebrew, Python 3.

**Spec:** `.claude/notes/dotconfig-review.md` (open findings), plus the decisions below. Line numbers there are pre-branch; re-locate by content.

## Global Constraints

- Branch `bugfix/dotconfig-review` is PR #13 → `develop`. Push after the final review.
- Commit as the global identity. Never override `user.*`.
- D4 = delete. D5 = untrack and delete from disk. D6 = track the lock file. (These are the tracker's defaults; the user said "do all".)
- **Keymaps are the user's.** Don't remap `gr` or the `w*` focus keys (same situation as marks `'`/`"`). ⚠ Confirm at plan review.
- **Tool-injected instruction blocks stay.** The CODEGRAPH blocks in `claude-code/CLAUDE.md` and `opencode/AGENTS.md` are rewritten by codegraph, and the user's global CLAUDE.md isn't ours to reorder. Don't touch them. ⚠ Confirm at plan review.
- Any change to `claude-code/settings.json` is applied to live `~/.claude/settings.json` too, so `claude-settings-sync` stays `in sync`. Back up live to the scratchpad first.
- Delete files outside the repo only after checking them: `~/.gitignore_global` (diff it against `git/ignore` first) and `zig@0.15` (check that nothing depends on it).
- tmux tests use a private socket plus a minimal conf only (see `.claude/knowledges/tmux-terminal.md`).

## Review Focus

1. **nvim startup and first file after the E tasks.** Expect `ts=true lsp≥1 colors=oxocarbon` for `.py`, `.json` and `.lua`, and no `:messages`. Every nvim task re-runs this.
2. **Blink completion after it loads earlier.** Insert mode must still complete and nothing may error. Headless check: `require('blink.cmp')` is loaded after BufReadPre.
3. **Undercurl after deleting the tmux `terminal-overrides`.** Re-run the private-socket `4:3` capture. The user confirms visually.
4. **git after the `.gitconfig` trim.** Global excludes still apply (via the XDG `git/ignore`). `git diff` still pages through delta. `git difftool --tool=nvimdiff` still works. Credentials still come from the keychain.
5. **Claude Code after the settings changes.** Live stays `in sync`, and no permission it actually uses is removed.

---

### Task 1: D4 — delete the root `AGENTS.md` and `CLAUDE.md`

**Files:** Delete `AGENTS.md`, `CLAUDE.md`
- [ ] Check (RED): `git ls-files AGENTS.md CLAUDE.md | wc -l` → 2.
- [ ] `git rm` both. Check: `git grep -n 'context-mode_ctx_' -- ':!.claude'` returns nothing outside opencode.
- [ ] Commit `chore: drop stale root agent instructions (context-mode injects its own)`.

### Task 2: D + D5 + D6 — untrack vendor/runtime files

**Files:**
- `git rm --cached`, keep on disk: `opencode/plugins/paseo-terminal-activity.js`, `opencode/package-lock.json`, `homebrew/trust.json.lock`, `opencode/effort-log.md`
- `git rm`, removed from disk: the 8 skills listed in the tracker (D5)
- Modify: the root `.gitignore`
  - add `/opencode/plugins/paseo-terminal-activity.js`, `/homebrew/trust.json.lock`, `/opencode/effort-log.md`
  - add the 8 skill paths
  - add opencode's `node_modules`, `package.json`, `package-lock.json` and `bun.lock` as `/opencode/…`
  - drop line 19 `nvim/nvim-pack-lock.json` (D6)
- Delete: `opencode/.gitignore` (it isn't tracked; its rules move to the root)
- Track: `nvim/nvim-pack-lock.json`

- [ ] Before deleting (D5), diff each skill against its staged upstream copy in `opencode/.oh-my-opencode-slim/`. **Stop and ask** if any file has user edits.
- [ ] Check (RED): `git ls-files` shows the 4 files and the 8 skills; `git check-ignore nvim/nvim-pack-lock.json` exits 0.
- [ ] Make the edits.
- [ ] Check (GREEN):
  - none of those paths is tracked
  - `git status --porcelain` shows no `??` for them
  - `git ls-files nvim/nvim-pack-lock.json` shows the lock file
- [ ] Commit `chore: untrack vendor/runtime files, track nvim pack lock`.

### Task 3: E1 — nvim LSP wiring

**Files:** `nvim/lua/plugins/lsp-config.lua`, `nvim/lua/plugins/blink-cmp-config.lua`

- `automatic_enable = { exclude = { 'ts_ls', 'omnisharp_mono' } }`
- Delete the redundant `make_client_capabilities()` merge.
- Blink loads before LSP: add `'saghen/blink.cmp'` to `mason_module.dependencies`, so blink's `plugin/` capability registration runs before any server starts.
- Inlay-hint `LspAttach`: call `nvim_clear_autocmds({ group = …, buffer = … })` before creating, the same way `lsp_highlight_symbol` does.
- Move the global `vim.diagnostic.config` from diagflow's `init` into `mason_module.config`.

- [ ] Check (RED), headless on a `.ts` file and `options.lua`:
  - (a) attached clients on the `.ts` file include both `ts_ls` and `vtsls`
  - (b) `package.loaded['blink.cmp']` is `nil` 4 s after opening a file
  - (c) `#nvim_get_autocmds({group=<inlay group>, buffer=0})` after `:LspRestart` + 3 s is > 1
- [ ] Implement.
- [ ] Check (GREEN):
  - (a) only `vtsls` attaches
  - (b) blink is loaded
  - (c) exactly 1 autocmd
  - Review Focus 1 passes
- [ ] Commit `fix(nvim): one TS server, blink capabilities before LSP, no stacked inlay autocmds`.

### Task 4: E2 — nvim options, ftplugins, side effects

**Files:**
- `nvim/after/ftplugin/qf.lua`: `vim.opt` / `vim.o` → `vim.opt_local`
- `nvim/lua/config/options.lua`: `wildignore` without the spaces, and `node_modules`
- `nvim/lua/config/keymaps.lua`: visual `p` must not hardcode `+`. Keep the mapping's intent (paste without clobbering the register) by using the unnamed register `"`.
- `nvim/lua/plugins/marks-config.lua`: move the `BufWritePost` autocmd out of `keys` into `config`, in an augroup.
- `nvim/lua/plugins/llm-config.lua`: move the top-level `VimResized` autocmd into the spec's `config`/`init`.
- `nvim/lua/plugins/treesitter-config.lua`: `event = { 'BufReadPre', 'BufNewFile', 'FileType' }`, so non-file buffers get treesitter.
- `nvim/lua/plugins/sessions-config.lua`: add a comment at `nested = true` explaining that it lets TS/LSP attach to restored buffers.

- [ ] Check (RED):
  - open qf, then a new buffer: `number` is off in the new buffer
  - `wildignore` contains `, `
  - `:enew | set ft=python`: TS inactive
  - `nvim_get_autocmds({event='BufWritePost'})` has no group for marks
- [ ] Implement.
- [ ] Check (GREEN): each check flips, and Review Focus 1 passes.
- [ ] Commit `fix(nvim): local qf options, wildignore, SSH-safe paste, plugin side effects in config`.

### Task 5: E3 + J nvim trivia — dead code

**Files:**
- Merge `plugins/colorscheme/oxocarbon-config.lua` into `plugins/colorscheme/init.lua` and delete it.
- Delete the dead `M.lualine` in `colorset.lua`.
- `lualine-config.lua`: delete the unused conditions (`buffer_not_empty`, `hide_in_width`, `check_git_workspace`) and the commented `diff` block.
- Typos: `blink-cmp-config.lua` `max_attemps` (delete the line); `snacks-config.lua` `bufdetele`.
- `after/lsp/lua_ls.lua`: drop the `use` global and keep one source of truth with `.luarc.json`. Keep `.luarc.json`, which lua_ls reads natively.
- `after/lsp/{jsonls,marksman,rust_analyzer,vue_ls}.lua` `return {}` stubs: replace with an explicit `ensure_installed` list in `lsp-config.lua` and delete the stubs.
- Delete the commented-out blocks listed in the review (keymaps, options, lsp-config, treesitter, llm-config).
- Redundant defaults: `Y`→`y$`, `incsearch`, `noremap`.
- Stale comments: "VeryLazy", `~/.config/nvim/lsp`, "noice chat sub-views"; stale marks excludes `toggleterm`, `lspinfo`.

- [ ] Check (RED): `git grep -c` for each deleted symbol or typo > 0.
- [ ] Implement.
- [ ] Check (GREEN): the greps return 0; Review Focus 1 passes; `jsonls`, `marksman`, `rust_analyzer` and `vue_ls` are still in mason's installed list.
- [ ] Commit `refactor(nvim): remove dead code, typos and commented blocks`.

### Task 6: F1 — tmux cleanup

**Files:**
- `tmux/tmux.conf`: delete the commented iTerm/WT/is_vim/old-colour blocks; delete the three `terminal-overrides` lines (`Tc`, `Smulx`, `Setulc`); merge the `RGB` and `usstyle` feature lines for `xterm-256color*` into one line.
- `git mv tmux/tmux.powerline.conf tmux/tmux.status.conf`, then:
  - delete the obsolete "keep status on" block
  - delete the duplicate `%hidden DIM/BORDER` and `status-style`
  - delete the copied pane-border comment and the commented powerline blocks
  - update the `source` line in `tmux.conf`

- [ ] Check (RED): `grep -c '^#' tmux/tmux.conf` > 40; `tmux.powerline.conf` exists.
- [ ] Implement.
- [ ] Check (GREEN):
  - the conf parses (`source-file -n`)
  - the private-socket undercurl test gives `4:3` ≥ 1
  - the status line format is unchanged: `show -gv status-right` / `status-left` on a private server loading `tmux.status.conf`, compared with before
- [ ] Commit `refactor(tmux): drop dead comments and duplicate overrides, rename status conf`.

### Task 7: F2 — zsh, Ghostty, installer

**Files:**
- `zsh/.zshrc`:
  - strip `*/fnm_multishells/*` from `path` before `fnm env`
  - guard `carapace` and `bun` with `(( $+commands[x] ))`
  - trim the nushell mentions in comments
- `zsh/.zprofile`: trim the nushell comment
- `ghostty/config`: `shell-integration-features = title` (keep any other features it lists), and trim the nushell comment
- `config-installer.sh`:
  - `read -r` at the four prompts
  - add `paseo` to `config_dirs`
  - cask comment `ghostty@tip font-maple-mono-nf`

- [ ] Check (RED):
  - in a nested shell, `zsh -lic 'zsh -ic "print -l \$path" | grep -c fnm_multishells'` > 1
  - `shellcheck config-installer.sh | grep -c SC2162` > 0
- [ ] Implement.
- [ ] Check (GREEN):
  - the fnm count is 1
  - SC2162 count is 0
  - `zsh -n` passes, and a login shell prints no errors
  - `ghostty +validate-config` passes
- [ ] Commit `fix(zsh,ghostty,installer): fnm PATH, guarded evals, read -r, paseo dir`.

### Task 8: G1 — git config

**Files:**
- `.gitconfig`:
  - drop `excludesfile` (XDG `git/ignore` takes over)
  - `~/` paths instead of `/Users/momeppkt`
  - drop `navigate=true`
  - drop `add.interactive.useBuiltin`
  - drop the `[credential]` block, only if `/opt/homebrew/etc/gitconfig` has `osxkeychain`
  - drop the built-in-identical `nvimdiff.cmd` and the commented line
- `claude-code/hooks/deny-git-identity-override.sh`: `identity='momeppkt <peeranut32@gmail.com>'` once; the four messages use `$identity`.
- `delta/themes.gitconfig`: keep only `[delta "oxocarbon"]`, without the no-op hunk-header sub-styles.
- Delete `~/.gitignore_global` after `diff` shows it matches `git/ignore`.

- [ ] Check (RED): `git config --show-origin --get core.excludesfile` → the `~/.gitignore_global` path.
- [ ] Implement.
- [ ] Check (GREEN):
  - `git check-ignore -v <a .DS_Store path>` names `git/ignore`
  - `git config credential.helper` → `osxkeychain`
  - `git difftool --tool-help | grep nvimdiff` works
  - `git -c core.pager=cat diff HEAD~1 --stat` works
  - a hook test (JSON on stdin with `git -c user.email=x commit`) prints a deny naming the identity
- [ ] Commit `chore(git): trim no-op gitconfig keys, use XDG ignore, DRY identity hook`.

### Task 9: G2 — CLI tool configs and `.gitignore`

**Files:**
- Delete `lazygit/vscode/config.yml`.
- `lazygit/config.yml`: delete `confirm-alt1`, the default-valued keys and the commented lines.
- `bat/config`: keep only the theme line.
- `aerospace/aerospace.toml`: delete the stock copy-comment and `after-login-command = []`.
- `brew untrust` the tap-covered `supabase/tap/supabase` and `nikitabobko/tap/aerospace`; commit the resulting `homebrew/trust.json`.
- Root `.gitignore`:
  - drop entries whose path no longer exists: flutter, fish/*, containers, lazy-lock, carapace/bridge, /.omc, opencode/context-mode/content, opencode-quota, .weave
  - dedupe `.claude/tmp`
  - drop `nushell/history.txt` and delete the `nushell/` dir
  - verify each path with `ls` first

- [ ] Check (RED): `lazygit --config-file lazygit/config.yml … ` prints no unknown-key warnings (lazygit validates at start). Record the current count of stale `.gitignore` lines.
- [ ] Implement.
- [ ] Check (GREEN):
  - `aerospace reload-config --dry-run` exits 0
  - `bat --list-themes | grep oxocarbon`
  - `git status --porcelain` shows no new `??`
  - stale-line count is 0
- [ ] Commit `chore: trim lazygit/bat/aerospace/brew trust and stale gitignore entries`.

### Task 10: H — claude-code settings template (and live)

**Files:** `claude-code/settings.json` and live `~/.claude/settings.json` (backed up first)
- Delete `statusLine` from the template only (it's in `IGNORED_KEYS`).
- Delete the curl-localhost allows (the deny wins).
- Delete the 7 individual `mcp__codegraph__codegraph_*` allows (`mcp__codegraph__*` covers them).
- Delete `modelSettings` (it duplicates the top-level `effortLevel`).
- Delete the playwright and supabase allows (neither plugin is enabled).

- [ ] Check (RED): the template has a `statusLine` key and the allow list has 25 entries.
- [ ] Implement it for the template. For live, apply the same removals except `statusLine` (claude-hud owns it). Round-trip formatting check, as in the termio removal.
- [ ] Check (GREEN): `claude-settings-sync` → `in sync`; the allow list has 15 entries.
- [ ] Commit `chore(claude-code): drop dead permissions and duplicate settings from template`.

### Task 11: I — script fixes

**Files:**
- `bin/paseo-repatch`:
  - `from __future__ import annotations`
  - `--quiet` also silences the notes loop
  - write the stamp only after the MISSED check passes
- `bin/claude-relink`: `target=$(readlink …) || target=`
- `bin/claude-settings-sync`:
  - `strip_vendor_hooks` tolerates `"command": null` and non-dict groups
  - `--write` keeps `hooks` in the repo's original position when the repo had none (insert where live has it)

- [ ] Check (RED):
  - `/usr/bin/python3 bin/paseo-repatch --help` crashes on annotations
  - `claude-relink` with `/opt/homebrew/bin/claude` absent (run with a temp `PATH`/prefix override, if the script allows; otherwise `bash -x` a sandbox copy) exits with no message
  - task5 test plus a new case (f) `{"command": null}` crashes
- [ ] Implement.
- [ ] Check (GREEN): all flip, and the task5 cases a–e still pass.
- [ ] Commit `fix(bin): python 3.9 compat, quiet mode, relink message, null-safe hook strip`.

### Task 12: J — docs and zig

**Files:**
- `README.md`:
  - tmux key table matches `tmux.conf` (splits `Enter`/`|`/`_`, sessions `H`/`L`)
  - `tmp` → `tpm`
  - a short Ghostty + starship section (cask `ghostty@tip`, font `font-maple-mono-nf`)
- `.claude/knowledges/zsh-shell-setup.md`: the `compinit` line matches `.zshrc`; the brew-wrapper section lists `paseo-repatch` and `claude-settings-sync`.
- `.claude/knowledges/zig-015-macos27-sdk.md`: `brew uninstall zig@0.15`, but first check `brew uses --installed zig@0.15` is empty. Then trim the note.

- [ ] Check (RED): `grep -c 'tmp' README.md` hits the typo; `brew list zig@0.15` exits 0.
- [ ] Implement.
- [ ] Check (GREEN): the typo is gone, the table matches `tmux list-keys -T prefix` on a private server, and zig@0.15 is uninstalled.
- [ ] Commit `docs: sync README and knowledge notes; drop zig@0.15`.

---

## Finish

- [ ] Final whole-branch review of the new range, including the anti-slop delta.
- [ ] Promote per CLAUDE.md: fold any new durable facts into `.claude/knowledges/`, and `git rm` this plan and `.claude/notes/dotconfig-review.md` if every item is resolved (otherwise trim the note to what's left).
- [ ] `git push`; update the PR #13 description with a section for the added batches.
