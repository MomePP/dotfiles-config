# zsh shell setup

The login shell, and how each tool plugs into it. Replaced nushell in
August 2026.

## Layout

zsh reads `.zprofile` and `.zshrc` from `$HOME` only (there is no `ZDOTDIR`
here), so `config-installer.sh` symlinks both out of `zsh/`:

| File | Holds | Runs |
| --- | --- | --- |
| `zsh/.zprofile` | `brew shellenv`, PATH, exported env | once per login shell |
| `zsh/.zshrc` | completions, prompt, vi mode, keybinds, aliases, functions | every interactive shell |

The split is deliberate: anything a non-interactive script needs (PATH,
`EDITOR`, `SDKROOT`) has to be in `.zprofile`, because `.zshrc` is not read
for `zsh -c`.

## Which zsh

System `/bin/zsh` (5.9), not Homebrew's. Homebrew ships 5.9.2 — a patch bump
with nothing user-visible. The system binary is already in `/etc/shells`, so
switching is `chsh -s /bin/zsh` with no `sudo` and no file edit, and a
half-failed `brew upgrade` can never leave the account without a login shell.

## Tool init — verified against the binaries, not upstream READMEs

Order in `.zshrc` matters: `compinit` first (carapace's init calls `compdef`,
which does not exist until the completion system is loaded), then the rest.

```zsh
autoload -Uz compinit && compinit -d "$XDG_CACHE_HOME/zsh/zcompdump"
source <(carapace _carapace zsh)
eval "$(starship init zsh)"
eval "$(fnm env --use-on-cd --shell zsh)"
eval "$(pyenv init - zsh)"
source <(SHELL=zsh bun completions)
```

Gotchas behind those lines:

- **`bun completions` reads `$SHELL`** and hard-errors on a value it does not
  recognise (`error: Unknown or unsupported shell`). Pinning `SHELL=zsh`
  inline keeps `.zshrc` sourceable from a shell started before `chsh` took
  effect, and from any subshell with an odd `$SHELL`. The emitted script ends
  in `compdef _bun bun`, so sourcing is correct — it does not need to be
  installed into `fpath` as `_bun`.
- **The compdump path is pinned.** `compinit` otherwise writes `.zcompdump`
  next to the rc file, which drops a generated file inside the tracked config
  dir on any `ZDOTDIR`-based launch. `.zshrc` `mkdir -p`s the cache dir first —
  the installer does not create it, so a fresh machine would fail on it.
- **`fnm --use-on-cd`** gives per-directory node switching on
  `.nvmrc`/`.node-version`. Under nushell this only ever existed as a
  commented-out `hooks.env_change.PWD` block.
- **`pyenv init - zsh`** does more than put shims on PATH: it also loads
  pyenv's completions and defines the `pyenv()` wrapper that makes
  `pyenv shell <version>` work.
- **carapace's `~/.config/carapace/bin` PATH entry is not lost under zsh.**
  Line 1 of `carapace _carapace zsh` is a *commented-out*
  `# export PATH="…/carapace/bin:$PATH"`, which reads like the behaviour is
  missing — but bisecting a login shell shows the dir still lands on PATH by
  another route inside the script. Nothing to add by hand.

## Completions

`brew shellenv` puts `/opt/homebrew/share/zsh/site-functions` on `FPATH`, so
`compinit` alone picks up the ~23 completions brew ships (`_bat _eza _fd _gh
_glab _delta _fnm _rustup _starship _git _brew _bun _carapace _aerospace
_ghostty _rg _ninja _mole _esptool _tree-sitter _claude-squad`).

No site-function ships for `lazygit`, `tmux`, or `cargo`. carapace covers
those, bridging to fish/bash/zsh specs via `CARAPACE_BRIDGES`.

## PATH

`.zprofile` lists entries low-to-high precedence and dedupes with
`typeset -U path`. pyenv shims and the fnm multishell dir are deliberately
*not* listed — their inits prepend them, which is how both tools expect to
work.

rustup is spelled `/opt/homebrew/opt/rustup/bin` rather than
`$(brew --prefix rustup)`: the `opt/` path is a stable symlink, and shelling
out to brew costs ~200ms on every login.

Resolved order, highest first:

```
~/.pyenv/shims                  # pyenv init
$FNM_MULTISHELL_PATH/bin        # fnm env
~/.config/carapace/bin          # carapace init
~/.local/share/nvim/mason/bin
~/.bun/bin
/opt/homebrew/opt/rustup/bin
~/.cargo/bin
~/.local/bin
/opt/homebrew/{bin,sbin}        # brew shellenv
/usr/local/bin /usr/bin /bin /usr/sbin /sbin
```

## Parity plugins

zsh has no built-in equivalent of nushell's inline history hints or command
syntax highlighting, so both come from Homebrew:

```bash
brew install zsh-autosuggestions zsh-syntax-highlighting
```

`.zshrc` sources them behind an existence check — a machine without them still
gets a working shell. `zsh-syntax-highlighting` must be sourced **last**; it
wraps every widget bound before it.

**Do not `bindkey '^[[C' autosuggest-accept`.** zsh-autosuggestions already
lists `forward-char` and `vi-forward-char` in
`ZSH_AUTOSUGGEST_ACCEPT_WIDGETS`, so right-arrow accepts the hint with no
binding at all. Binding the key directly *replaces* `forward-char`, which
breaks plain rightward cursor movement whenever no suggestion is showing.

## The `brew` wrapper is load-bearing

`.zshrc` defines a `brew` function that re-runs `claude-relink` after every
invocation, on both the success and failure paths — a partly-failed
`brew upgrade` may still have upgraded claude-code. macOS TCC grants app-data
access by absolute path and the claude-code cask installs to a version-stamped
dir, so without the relink every upgrade re-triggers "Data Access Blocked".

It also mirrors brew's own split for the Espressif clangd fork, which has no
formula and no PlatformIO package: `esp-clangd-update --check` on `update`
(reports what is available), `--quiet` on `upgrade` (installs it). Only those
two subcommands, since each costs a GitHub API call and `brew --prefix`-style
invocations must stay cheap.

## Everything else inherits the login shell

tmux (no `default-shell`/`default-command`), ghostty, kitty, herdr, lazygit,
gh-dash, aerospace, opencode, superset, and every LaunchAgent pick the shell
up from the passwd entry — none of them pin one. nvim sets no `vim.o.shell`.
`bin/claude-relink` and `bin/esp-clangd-update` are `#!/bin/sh`.

Consequence when switching: a **running** tmux server captured `default-shell`
at start, so new panes keep spawning the old shell until `tmux kill-server`.
Same for already-open terminal tabs.

## Listing: `l`/`la`/`ll`/`lla`/`lt` are eza shaped like nushell's `ls`

nushell's builtin `ls` was a structured table; BSD `ls -l` is nothing like it
and eza is close. All five wrappers share one flag array:

```zsh
--long --header --time-style=relative --icons=always --git --classify=always
```

`l`/`la` add `--no-permissions --no-user`, `ll`/`lla` add `--smart-group` — the
same split nushell had between `ls` and `ls -l`. Type is carried by the icon
plus the `--classify` suffix (`/` dir, `*` executable, `@` symlink) rather than
a column of its own.

**eza cannot reproduce nushell's box borders or its `#` index column.** There is
no border, table, or index flag in the full option list; that rendering belongs
to nushell's table renderer, not to a listing tool. Everything else — columns,
header row, relative timestamps, icons, git status — matches. Colors are
tunable through `EZA_COLORS` or a `theme.yml` under `EZA_CONFIG_DIR`.

Two eza traps these wrappers are built around:

- **`--icons` takes an *optional* value and greedily swallows the next
  argument**, so `eza -l --icons .` dies with
  `invalid value '.' for '--icons'`. Always spell it `--icons=always`.
- **Bare `eza` with no path argument prints nothing** on this machine — 0
  bytes, exit 0, with or without flags, in and out of a sandbox — while
  `eza .` works. That is why these are functions passing `"${@:-.}"` rather
  than plain aliases. eza 0.23.5; recheck if a later version fixes it.
