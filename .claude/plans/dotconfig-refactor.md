# Dotconfig Refactor (batches A, B, C + D3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the high-severity bugs found in the 2026-09-28 review, remove Superset/Kitty/OpenAgentsControl leftovers and dead nvim code, and make tmux panes use `tmux-256color` with working undercurl.

**Architecture:** Config-only edits in `~/.config`, one commit per task, on a git-flow bugfix branch. Each task ends with a check that runs headless, so nothing touches the user's running tmux server or nvim sessions.

**Tech Stack:** Neovim nightly + zpack (vim.pack), zsh, tmux 3.7c, Ghostty tip, Homebrew, Python 3 (`bin/claude-settings-sync`).

**Spec:** `.claude/notes/dotconfig-review.md` (batches A, B, C and decision D3), plus the user decisions below.

## Global Constraints

- Branch: `bugfix/dotconfig-review` from `develop`; record `git config gitflow.branch.bugfix/dotconfig-review.base develop`.
- Commit as the configured global identity. Never pass `-c user.*`, `GIT_AUTHOR_*`, or `git config user.*` (a hook blocks these).
- D1: tmux `allow-passthrough on` **stays on**. Don't touch `tmux.conf:93-94`.
- D2: `.gitconfig` email **stays** as it is. Out of scope.
- D3: `default-terminal` becomes `tmux-256color`. (`ghostty-256color` doesn't exist; Ghostty's own entry is `xterm-ghostty`, used outside tmux.) Undercurl must work inside and outside tmux.
- Tests never use the user's tmux server: always `tmux -L dotcfg-test` with a minimal conf file in the scratchpad, then kill that socket.
- Keep `context7` in `opencode/oh-my-opencode-slim.json`. That's the MCP server, not the deleted skill.
- Keep `set -g allow-passthrough on` and its "Kitty graphics protocol" comment. That's the protocol's name, not a kitty reference.
- Out of scope (not approved): batches D–J, except D3.

## Review Focus

1. **Session restore at startup** (resession loads buffers before any `BufReadPre` from a user-typed file). TS and LSP must still attach to restored buffers. This is covered in Task 1 Step 4.
2. **`nvim` with no args, then `:e file`.** This worked before and must keep working after the event change. Covered in Task 1 Step 4.
3. **Colorscheme load after deleting its duplicate spec.** `vim.g.colors_name` must still be `oxocarbon` with no startup errors. Covered in Task 8 Step 3.
4. **`claude-settings-sync` when live has only vendor hooks added.** It must report no drift. When the user's own hook changes, it must report drift. Covered in Task 5 Step 1.
5. **ssh from a tmux pane to a host without `tmux-256color` terminfo.** The existing `ssh()` wrapper at `zsh/.zshrc:213` pins `TERM=xterm-256color`, so no change is needed. Task 10 Step 5 confirms the wrapper is still there.

---

## Batch A — High-severity bugs

### Task 1: nvim — treesitter and LSP attach to the first file opened

**Files:**
- Modify: `nvim/lua/plugins/treesitter-config.lua:5`
- Modify: `nvim/lua/plugins/lsp-config.lua:10`

- [ ] **Step 1: Write the check script** `$SCRATCH/nvim-first-file.sh`:
  it takes a file path, then runs
  `nvim --headless -i NONE "$1" +'lua vim.defer_fn(function() local b=vim.api.nvim_get_current_buf(); io.stdout:write(("ts=%s lsp=%d\n"):format(vim.treesitter.highlighter.active[b]~=nil, #vim.lsp.get_clients({bufnr=b}))); vim.cmd("qa!") end, 4000)'`.
- [ ] **Step 2: Run it to confirm the bug**
  Run it against a scratch `.py` file and against `nvim/lua/config/options.lua`.
  Expected: `ts=false` for the `.py` file and `lsp=0` for `options.lua`.
- [ ] **Step 3: Change both specs** from `event = 'BufEnter'` to `event = { 'BufReadPre', 'BufNewFile' }`.
- [ ] **Step 4: Run the check again**
  Expected: `ts=true` for the `.py` file, and `ts=true lsp>=1` for `options.lua`.
  Then run the no-args case:
  `nvim --headless -i NONE +'e nvim/lua/config/options.lua' +'lua vim.defer_fn(...same...)'`.
  Expected: `ts=true lsp>=1`.
  Then open nvim normally in a repo with a saved session and confirm the restored buffers highlight. This one is manual; note the result.
- [ ] **Step 5: Commit** `fix(nvim): load treesitter and lsp before the first buffer's FileType`

### Task 2: ~~marks keys~~ — DROPPED

User decision 2026-09-28: `'` and `"` are deliberately mapped to marks.nvim. No change.

### Task 3: installer — works on a fresh machine

**Files:**
- Modify: `config-installer.sh:4`

- [ ] **Step 1: Confirm the failure**
  Run `HOMEBREW_NO_AUTO_UPDATE=1 brew install --dry-run <line-4 formula list>`.
  Expected: it errors on `aerospace`.
- [ ] **Step 2: Edit line 4**
  - `aerospace` → `nikitabobko/tap/aerospace`
  - drop `wget`
  - add `oven-sh/bun/bun` and `jq`
- [ ] **Step 3: Check the edit**
  Run the same dry-run with the new list. Expected: exit 0 and no "No available formula".
  Then run `bash -n config-installer.sh`. Expected: exit 0.
- [ ] **Step 4: Commit** `fix(installer): resolve aerospace via its tap, add bun and jq, drop unused wget`

---

## Batch B — Superset purge (Superset was uninstalled in bbb02b5)

### Task 4: remove Superset wiring

**Files:**
- Delete: `.superset/config.json`
- Delete: `.claude/knowledges/superset-transparency.md` (it has no Paseo content to salvage)
- Modify: `config-installer.sh` — drop `superset` from `config_dirs` (line 143), and delete the `superset-repatch` comment and `symlink_config` block (lines 195-200)
- Modify: `claude-code/.gitignore:52-55` — delete the `/skills/superset/` block
- Modify: `bin/paseo-repatch` — rewrite the comments at 108-109, 204, 220, 274, 286-287 and 1328 so they describe Paseo alone. The colour remap is defined in this script, not in `superset/oxocarbon-glass.json`. Comments only; no code changes.
- Modify: `.claude/knowledges/zsh-shell-setup.md:137` — drop `superset,`

- [ ] **Step 1: Make the edits above.**
- [ ] **Step 2: Verify**
  - `grep -rni superset --exclude-dir=.git . | grep -v '.claude/notes\|.claude/plans'` prints only `.claude/knowledges/claude-settings-ownership.md` and `bin/claude-settings-sync`. Task 5 handles both.
  - `bash -n config-installer.sh` exits 0.
  - `python3 -m py_compile bin/paseo-repatch` exits 0.
- [ ] **Step 3: Commit** `chore(superset): drop remaining Superset wiring after uninstall`

### Task 5: claude-settings-sync — track your own hooks, ignore only vendor ones

**Files:**
- Modify: `bin/claude-settings-sync`
- Modify: `.claude/knowledges/claude-settings-ownership.md`

**Interfaces:**
- Produces: `VENDOR_HOOK_MARKERS: tuple[str, ...] = ("context-mode-cache-heal.mjs",)`
- Produces: `strip_vendor_hooks(hooks: dict | None) -> dict | None`. It drops every hook entry whose `command` contains a marker, then drops any matcher group left with no hooks, then any event left empty. It returns `None` if nothing remains.
- `IGNORED_KEYS` becomes `{"statusLine"}`. Before comparing, both `live["hooks"]` and `repo["hooks"]` go through `strip_vendor_hooks`, and `--write` ports the stripped live value. Add the future import at the top so it runs on `/usr/bin/python3` 3.9.

- [ ] **Step 1: Write the test** `$SCRATCH/test-settings-sync.sh`. It builds a fake `$HOME` with `.claude/settings.json` and `.config/claude-code/settings.json` and runs `HOME=$fake python3 bin/claude-settings-sync` in three cases:
  - (a) repo hooks = your PreToolUse hook; live = the same plus the context-mode SessionStart entry. Expect exit 0, `in sync`.
  - (b) live changes your hook's `timeout`. Expect exit 1, output contains `hooks`.
  - (c) (b) with `--write`, using a fake `$HOME` that is not a git repo so staging fails gracefully. Expect the repo file's hooks to hold the new timeout and **no** context-mode entry.
- [ ] **Step 2: Run the test.** Expect (a) to fail, because `hooks` is fully ignored today, so (b) reports nothing.
- [ ] **Step 3: Implement** the interfaces above. Rewrite the module docstring and the `IGNORED_KEYS` comment without Superset: the file isn't symlinked because Claude Code writes `/config` changes into it.
- [ ] **Step 4: Run the test.** Expect all three to pass. Also run `/usr/bin/python3 bin/claude-settings-sync --help` and expect exit 0.
- [ ] **Step 5: Rewrite `claude-settings-ownership.md`**
  - Frame it around the surviving reason: `/config` writes, and the `remoteControlAtStartup` drift story.
  - Replace the Superset-test and "survives a rewrite" sections with one line on what `strip_vendor_hooks` ignores.
  - Keep the claude-hud copy-not-symlink section as it is.
- [ ] **Step 6: Commit** `refactor(claude-settings-sync): drift-check own hooks, ignore only vendor entries`

---

## Batch C — Remove legacy tools and dead code

### Task 6: remove Kitty

**Files:**
- Delete: `kitty/` (15 files)
- Modify: `zsh/.zshrc:204` — delete the `kssh` alias
- Modify: `tmux/tmux.conf:7` — delete the commented `xterm-kitty` line (Task 10 rewrites lines 5-8 anyway; skip this if doing Task 10 in the same pass)
- Modify: `config-installer.sh:10` — change the comment to `# brew install --cask ghostty@tip`. Line 143: drop `kitty` from `config_dirs`
- Modify: `README.md:114` — delete the kitty note
- Modify: `.claude/knowledges/zsh-shell-setup.md:136` — drop `kitty,`

- [ ] **Step 1: Make the edits.**
- [ ] **Step 2: Verify**
  - `git grep -ni kitty` prints only the `Kitty graphics protocol` comment in `tmux.conf`.
  - `zsh -n zsh/.zshrc` exits 0.
  - `bash -n config-installer.sh` exits 0.
- [ ] **Step 3: Commit** `chore(kitty): remove legacy kitty config`

### Task 7: remove OpenAgentsControl leftovers

**Files:**
- Delete: `opencode/skills/task-management/`, `opencode/skills/context7/`, and the `Claude` symlink at the repo root
- Modify: `opencode/AGENTS.md:7-24` — delete the "Path Compatibility" section

- [ ] **Step 1: Make the edits.**
- [ ] **Step 2: Verify**
  - `git grep -n 'ContextScout\|task-management\|config/Claude'` prints nothing.
  - `git grep -n context7` prints only `opencode/oh-my-opencode-slim.json`.
- [ ] **Step 3: Commit** `chore(opencode): remove OpenAgentsControl leftovers`

### Task 8: nvim — delete dead colorscheme code and fn-utils

**Files:**
- Delete: `nvim/lua/plugins/colorscheme/nightfox-config.lua`, `nvim/lua/plugins/colorscheme/flatwhite-config.lua`, `nvim/lua/plugins/colorscheme-config.lua`, `nvim/lua/config/fn-utils.lua`
- Modify: `nvim/lua/plugins/colorscheme/init.lua`
  - drop the `fn-utils` require
  - `M = vim.tbl_extend('force', M, theme.info)`
  - delete the `M.colors` and `M.lualine` lines, which have no consumers
- Modify: `nvim/lua/plugins/colorscheme/oxocarbon-config.lua` — delete `M.lualine` and `M.colors`, which this change orphans
- Modify: `nvim/lua/plugins/lualine-config.lua:8,29` — drop the `utils` require; `utils.is_loaded('blink.cmp')` → `package.loaded['blink.cmp'] ~= nil`

- [ ] **Step 1: Record the baseline**
  `nvim --headless -i NONE +'lua io.stdout:write((vim.g.colors_name or "none").."\n")' +'lua vim.defer_fn(function() io.stdout:write(vim.fn.execute("messages")); vim.cmd("qa!") end, 2000)'`
  Note the output: expect `oxocarbon` and no errors.
- [ ] **Step 2: Make the edits.**
- [ ] **Step 3: Verify**
  - Re-run Step 1. The output must be identical, with no `E5108`/`module ... not found`.
  - `git grep -n 'fn-utils' nvim` prints nothing.
  - Re-run Task 1's check on `options.lua`. Expect `ts=true lsp>=1`.
- [ ] **Step 4: Commit** `refactor(nvim): delete unused colorschemes and fn-utils`

### Task 9: zsh — dead alias and carapace bridges

**Files:**
- Modify: `zsh/.zshrc:195` — delete `rbrew`
- Modify: `zsh/.zprofile:41` — `CARAPACE_BRIDGES='zsh,bash'`

- [ ] **Step 1: Make the edits.**
- [ ] **Step 2: Verify**
  - `zsh -n zsh/.zshrc && zsh -n zsh/.zprofile` exits 0.
  - `zsh -lic 'echo ok' 2>&1 | tail -1` prints `ok` with no error lines before it.
- [ ] **Step 3: Commit** `chore(zsh): drop dead rbrew alias and uninstalled carapace bridges`

---

## D3 — tmux terminal type

### Task 10: `default-terminal tmux-256color` with working undercurl

**Files:**
- Modify: `tmux/tmux.conf:5-8` — replace the two commented alternatives and `set -g default-terminal $TERM` with `set -g default-terminal tmux-256color`

- [ ] **Step 1: Write the test** `$SCRATCH/tmux-undercurl.sh`
  1. Build `$SCRATCH/tmux-min.conf` from `grep -E '^set.*(default-terminal|terminal-features|terminal-overrides)' tmux/tmux.conf`.
  2. Run `tmux -L dotcfg-test -f $SCRATCH/tmux-min.conf new -d -x 60 -y 5 'nvim --clean +"set tgc" +"call setline(1,\"curly\")" +"hi X gui=undercurl guisp=red" +"call matchadd(\"X\",\"curly\")"'`.
  3. `sleep 1`, then `tmux -L dotcfg-test display -p '#{client_termname}' ; tmux -L dotcfg-test show -gv default-terminal`.
  4. Run `tmux -L dotcfg-test capture-pane -p -e | grep -c '4:3'`.
  5. Run `tmux -L dotcfg-test kill-server`.
  6. Print the TERM seen inside the pane: add `+"lua io.open(os.getenv('SCRATCH')..'/term','w'):write(vim.env.TERM)"` to the nvim command.
- [ ] **Step 2: Run it before the change.** Record the TERM and the `4:3` count.
- [ ] **Step 3: Edit `tmux.conf:5-8`.**
- [ ] **Step 4: Run the test again.** Expected: TERM inside the pane is `tmux-256color` and the `4:3` count is ≥1 (tmux stored an undercurl cell from nvim).
  If the count is 0: nvim didn't emit undercurl for `tmux-256color`. Add `set -as terminal-overrides ',tmux-256color:Smulx=\E[4::%p1%dm'` **only if** that fixes the count, and record why in a comment.
- [ ] **Step 5: Manual check (user)**
  - In a new Ghostty window **outside** tmux: `printf '\e[4:3mcurly\e[0m\n'`. It must look curly.
  - Then `tmux source ~/.config/tmux/tmux.conf`, open a **new** pane (existing panes keep the old TERM), and repeat the `printf`. Then open a file with a diagnostic in nvim. Both must look curly.
  - Confirm `grep -n 'ssh()' zsh/.zshrc` still shows the wrapper.
- [ ] **Step 6: Commit** `fix(tmux): use tmux-256color as default-terminal`

---

## Finish

- [ ] Run a whole-branch review (anti-slop delta included).
- [ ] Promote per CLAUDE.md:
  - Fold durable facts into `.claude/knowledges/` (tmux terminal choice → `tmux-agent-dock.md` or a new `tmux-terminal.md`; claude-settings-sync behaviour is already in `claude-settings-ownership.md`).
  - `git rm` this plan and the review note in the closing commit.
- [ ] Hand off via superpowers:finishing-a-development-branch.
