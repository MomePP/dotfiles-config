# nvim nightly: bufload'ed buffers turn spuriously 'modified' on first display

**Status**: live regression on nvim master as of 2026-07-23; not reported
upstream (by choice). Stable 0.12.4 unaffected. **Resolved for this config by
switching session management to mini.sessions** (2026-07-23), which never
calls `bufload()` — the regression cannot trigger. No workaround code remains.

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

## How it broke resession.nvim (historical)

resession restored buffers via `bufload()` under `eventignore=all`, then
relied on a per-buffer once `BufEnter → :edit` (with `emsg_silent`) to
trigger filetype detection + treesitter. The spurious modified flag made that
`:edit` abort with a hidden E37 → no filetype, no TS highlight, ● modified
marker — and the VimLeavePre auto-save then wrote `"filetype": ""` back into
the session JSON (feedback loop). Upstream report of the same bug (same
`bufload` line, same nightly window, cause unidentified there):
stevearc/resession.nvim#86.

A config-side workaround (clear the spurious flag before resession's `:edit`,
guarded by buffer-content == disk-content) lived briefly on branch
`fix/nvim-resession-nightly-modified` (deleted; commits ea43ea3/0c566b0 in
reflog history only). Superseded by the mini.sessions switch: native
`:mksession`/`:source` restores background buffers with `:badd` (never
loaded) and window buffers through the normal edit path — no `bufload()`.

## Hard-won gotchas (cost real debugging time)

- **Don't guard "spurious modified" on empty undo history**: with
  `'undofile'` enabled, restored buffers load their old undo tree from disk
  (`undotree(buf).seq_last` was 231 on a freshly-restored, untouched buffer).
  Compare buffer content against the file on disk instead.
- **Headless tests mask window-focus behavior**: `--headless` never fires
  `UIEnter` (deferred user config never loads) and probes that cycle windows
  deliver BufEnter events a real user hasn't produced yet. To verify
  real-GUI behavior, run nvim in a PTY and query remotely:
  `script -q /dev/null nvim --listen /tmp/x.sock &` then
  `nvim --server /tmp/x.sock --remote-expr 'luaeval(...)'`. Inspect actual
  painted cells with `vim.fn.screenattr(row, col)` / `screenstring`.
- Bisect harness pattern that worked: blobless clone
  (`git clone --filter=blob:none`), `git bisect run` with a script that
  builds (`make CMAKE_BUILD_TYPE=Release`, exit 125 on build failure) and
  checks the one-line repro via `VIMRUNTIME=$PWD/runtime ./build/bin/nvim
  --headless --clean -S test.lua`. ~11 steps over 1401 commits, ~40 min.

## If it resurfaces

The regression still exists in nvim master — anything that `bufload()`s a
buffer that later gets displayed (other plugins do this too) can show the
same spurious-modified symptom. Retest with the minimal repro above; watch
`src/nvim/context.c` history after commit `6a8bb2d62` for the upstream fix.
