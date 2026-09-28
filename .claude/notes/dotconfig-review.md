# Dotconfig review — open items

Every finding from the 2026-09-28 review has shipped on `bugfix/dotconfig-review`
(PR #13), except the ones below. Lessons live in `.claude/knowledges/`.

## Kept by decision — don't re-raise

- nvim `'`/`"` (marks.nvim), `gr` and the `w*` window keys: the user's keymaps.
  The 400 ms wait from sharing a prefix with built-ins is accepted.
- Tool-injected CODEGRAPH blocks in `claude-code/CLAUDE.md` and `opencode/AGENTS.md`.
- `.gitconfig` gmail identity; tmux `allow-passthrough on`.

## Deferred minors

- `bin/paseo-repatch`: the "is running — quit it first" exit (1) comes before
  the MISSED report, and the brew wrapper's `|| true` swallows it, so a broken
  patch is only reported when Paseo is closed during `brew upgrade`.
- `bin/claude-settings-sync` `strip_vendor_hooks`: a group whose `"hooks"` is
  `null` still raises; use `g.get("hooks") or []`.
- `nvim/lua/plugins/lsp-config.lua`: the global `vim.diagnostic.config` sits
  in the mason-lspconfig spec's `config`; the diagnostic spec's `config` or
  `config/options.lua` is the better home.
- `brew uninstall zig@0.15` auto-removed `llvm@20`; any other orphaned
  dependency it removed wasn't captured.
