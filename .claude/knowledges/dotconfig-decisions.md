# Dotconfig: kept by decision — don't re-raise

Settled with the user during the 2026-09-28 review of `~/.config`. A review
that flags these as problems is wrong about intent, not about mechanics.

- **nvim `'` and `"`** are marks.nvim next/prev mark (`config/keymaps.lua`,
  `keymaps.marks`), in place of built-in mark jumps and register selection.
- **nvim `gr`** (snacks LSP references) and the **`w*` window keys** (`wh/wj/wk/wl`
  focus.nvim splits, `wt` size toggle, `wq` close, `wQ` bufdelete) stay. The
  400 ms `timeoutlen` wait from sharing a prefix with nvim's `gr…` defaults and
  the `w` motion is accepted.
- **Tool-injected CODEGRAPH blocks** in `claude-code/CLAUDE.md` and
  `opencode/AGENTS.md` stay as written; codegraph rewrites them, and the global
  CLAUDE.md is the user's.
- **git identity** is `momeppkt <peeranut32@gmail.com>` in a public repo, on
  purpose — see `git-config.md`.
- **tmux `allow-passthrough on`** stays (Kitty graphics for Ghostty); the old
  ocv hang no longer applies, ocv isn't used.
