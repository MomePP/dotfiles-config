# nvim nightly: bufload'ed buffers turn spuriously 'modified' on first display

**Status**: live regression on nvim master as of 2026-07-22, worked around in
`nvim/lua/plugins/resession-config.lua` (branch `fix/nvim-resession-nightly-modified`).
Not reported upstream (by choice). Stable 0.12.4 unaffected.

## The bug

Culprit commit (found by full git bisect, v0.12.4 merge-base → `HEAD-69e1321`,
1401 commits, every step built + tested):

- `6a8bb2d62f311b12a26d7dbc75dcdac94208b2ef`
  — "refactor(ctx): simplify ctx_switch" (PR neovim/neovim#40674, 2026-07-10)
- It removed the `win_enter(cw_win)` call from the temporary "autocmd window"
  (`ctx_win_prep` in `src/nvim/context.c`) that `bufload()` uses internally,
  skipping window-entry bookkeeping.

Minimal repro (`nvim --clean`, zero plugins):

```lua
local b = vim.fn.bufadd('some-file.lua')
vim.fn.bufload(b)
vim.api.nvim_win_set_buf(0, b)   -- any first display: :buffer, win_set_buf, ...
print(vim.bo[b].modified)        -- nightly: true (BUG) | stable: false
```

The flag is fully spurious: changedtick untouched, no undo entries, buffer
content byte-identical to disk. `FileChangedShell` does not fire (timestamp
check ruled out). No error surfaces even with `:set debug=msg`.

## Failure chain through resession.nvim

1. resession restores buffers via `bufload()` under `eventignore=all`, then
   relies on a per-buffer once `BufEnter → :edit` (with `emsg_silent`) to
   trigger filetype detection + treesitter.
2. The spurious modified flag makes that `:edit` abort with a **hidden E37**
   → no filetype, no TS highlight, buffer shows ● modified.
3. Worse: the VimLeavePre auto-save then writes `"filetype": ""` back into the
   session JSON — a feedback loop. (It self-heals once `:edit` works again.)

## The workaround (in resession-config.lua, TODO-marked for removal)

Clear the bogus flag just before resession's `:edit` can run:

- **BufEnter autocmd**, created at plugin setup so it fires *before*
  resession's per-buffer once-autocmd (autocmds run in creation order) —
  covers background buffers entered after restore. Keyed on resession's
  private `vim.b._resession_need_edit` flag.
- **post_load hook** healing **every visible window** — non-current windows
  never fire their deferred BufEnter until focused, so run the `:edit`
  ourselves via `nvim_win_call`. The current window only needs the flag
  cleared (resession runs its own final `:edit` right after the hooks —
  `dispatch("post_load")` happens *before* that edit in resession's `load()`).

Safety guard: **buffer content == disk content** (`vim.fn.readfile` vs
`nvim_buf_get_lines`), so genuine edits are never discarded. No-op on
stable/fixed builds.

## Hard-won gotchas (cost real debugging time)

- **Don't guard on empty undo history**: with `'undofile'` enabled, restored
  buffers load their old undo tree from disk (`undotree(buf).seq_last` was
  231 on a freshly-restored, untouched buffer). First workaround version
  silently no-op'd because of this.
- **Headless tests mask the visible-window gap**: `--headless` runs never
  fire `UIEnter` (deferred user config never loads) and a probe that cycles
  windows accidentally delivers the BufEnter that a real user hasn't done
  yet. To verify real-GUI behavior, run nvim in a PTY and query remotely:
  `script -q /dev/null nvim --listen /tmp/x.sock &` then
  `nvim --server /tmp/x.sock --remote-expr 'luaeval(...)'`.
- Bisect harness pattern that worked: blobless clone
  (`git clone --filter=blob:none`), `git bisect run` with a script that
  builds (`make CMAKE_BUILD_TYPE=Release`, exit 125 on build failure) and
  checks the one-line repro via `VIMRUNTIME=$PWD/runtime ./build/bin/nvim
  --headless --clean -S test.lua`. ~11 steps over 1401 commits.

## Exit criteria

Remove the workaround block (and this file's "Status" line) when upstream
fixes the regression — watch `src/nvim/context.c` history after commit
`6a8bb2d62`, or just retest the minimal repro on a newer nightly.
