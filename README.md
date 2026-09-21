# MomePP's dotfiles
> Requires `Homebrew` to be installed

## Install
The repo is meant to *be* `~/.config`. Clone it there and run the installer —
cwd does not matter, it resolves its own directory:

``` bash
git clone https://github.com/MomePP/dotfiles-config ~/.config
~/.config/config-installer.sh
```

`config-installer.sh` brew-installs the CLI tools, then leaves everything that
already sits in `~/.config` alone and only creates the links that have to live
outside it (`~/.gitconfig`, `~/.zshrc`, `~/.zprofile`, `~/.claude/*`,
`~/.local/bin/*`). It detects that case itself: when the clone *is* the install
target it prints `kept <name> config in place..` and copies nothing, so there is
no window where a tracked directory is removed before being rewritten. A clone
kept somewhere else — `~/dotfiles`, say — copies each tracked directory into
`~/.config` instead. Anything outside `~/.config` prompts before it is replaced,
so the script needs a terminal; do not detach it or pipe it to a pager.

`git clone` refuses a `~/.config` that already exists and is not empty. Graft
the repo onto it instead:

``` bash
git clone --no-checkout https://github.com/MomePP/dotfiles-config /tmp/dotfiles-config
mv /tmp/dotfiles-config/.git ~/.config/.git
rm -rf /tmp/dotfiles-config
cd ~/.config && git checkout develop -- .
```

Left out of the installer on purpose:

``` bash
chsh -s /bin/zsh              # see zsh below
brew trust nikitabobko/tap    # the aerospace cask is from an untrusted tap
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

> tpm has to live at `~/.config/tmux/plugins/tpm` — the path `tmux.conf` sources
> on its last line — not at tpm's own documented `~/.tmux/plugins/tpm`. tmux
> ignores a failing `run` silently, so a tpm in the wrong place leaves
> `<prefix>I` unbound with no error anywhere.

## Neovim
<img width="1672" alt="Image" src="https://github.com/user-attachments/assets/4031c96c-a562-4d4f-8946-9565a7aff63f" />

`config-installer.sh` installs the config; plugins are not tracked here. Neovim
bootstraps them on first launch — [`lua/zpack-config.lua`](nvim/lua/zpack-config.lua)
pulls [zpack.nvim](https://github.com/zuqini/zpack.nvim) via `vim.pack.add`, and
the resolved revisions land in the untracked `nvim/nvim-pack-lock.json`.

#### Keybindings
Most of the keybindings can be modified in [keymaps.lua](nvim/lua/config/keymaps.lua).

#### Plugins
All the installed plugins are listed in [plugins/init.lua](nvim/lua/plugins/init.lua) or [plugins/](nvim/lua/plugins/)

## zsh
The login shell. Uses the zsh macOS ships (`/bin/zsh`, 5.9) — Homebrew's is
5.9.2, a patch bump with nothing user-visible, and the system one is already
listed in `/etc/shells` so it needs no `sudo` and cannot leave the account
shell-less if a `brew upgrade` fails part-way.

``` bash
chsh -s /bin/zsh
```

`config-installer.sh` symlinks both rc files, which zsh only reads from `$HOME`:

| File | Holds |
| --- | --- |
| [`zsh/.zprofile`](zsh/.zprofile) | `brew shellenv`, PATH, exported env — runs once per login shell |
| [`zsh/.zshrc`](zsh/.zshrc) | completions, prompt, vi mode, keybinds, aliases, functions |

Tool init lives in `.zshrc`: `starship`, `carapace` (after `compinit`, which it
needs for `compdef`), `fnm --use-on-cd`, `pyenv init -`, and `bun completions`.
Most CLI completions come free — `brew shellenv` puts
`/opt/homebrew/share/zsh/site-functions` on `FPATH` and `compinit` picks them
all up; carapace covers what brew does not ship (`lazygit`, `tmux`, `cargo`).

Inline hints and syntax highlighting are the two things zsh does not have built
in. `config-installer.sh` installs them; `.zshrc` sources both behind an
existence check, so a machine without them still gets a working shell.

``` bash
brew install zsh-autosuggestions zsh-syntax-highlighting
```

> The `brew` function in `.zshrc` is not a convenience — it re-runs
> `claude-relink` after every invocation. macOS TCC grants app-data access by
> absolute path and the claude-code cask installs to a version-stamped dir, so
> without it every `brew upgrade` re-triggers "Data Access Blocked".

## tmux
Requires `tmux` and `tmp`(tmux plugins manager)

Already configured with following keybindings
- **Session** - follow by uppercase-letter
- **Window** - follow by Ctrl-key to hold
- **Pane** - follow by lowercase-letter

| **Actions**     | Session                    | Window                             | Pane                       |
| :---        | ---                        | ---                                | ---                        |
| new         | `<prefix>N`                | `<prefix><C-n>`                    | `<prefix>n`                |
| next        | `<prefix>J` or `<prefix>O` | `<prefix><C-j>` or `<prefix><C-o>` | `<prefix>j` or `<prefix>o` |
| previous    | `<prefix>K`                | `<prefix><C-k>`                    | `<prefix>k`                |
| kill        | `<prefix>X`                | `<prefix><C-x>`                    | `<prefix>x`                |

##### Note about tmux terminfo
the correct way to set up tmux terminfo on macOS, we need to compile the description by using `infocmp` from latest ncurses → [Ref. Notes](https://gist.github.com/joshuarli/247018f8617e6715e1e0b5fd2d39bb6c)

> If you are using kitty terminal, needed to set terminfo to `xterm-kitty`. otherwise, the undercurl is not usable.

``` bash
# install latest ncurses
brew install ncurses

# export tmux terminfo
/opt/homebrew/Cellar/ncurses/<version>/bin/infocmp tmux-256color > ~/tmux-256color.info

# compiling terminfo description to system database
sudo tic -xe tmux-256color ~/tmux-256color.info
```

## Touch ID for sudo
Not in the dotfiles — the file lives in `/etc` — so it is the one thing a new
machine loses silently: `sudo` just asks for a password and nothing says why.
`/etc/pam.d/sudo` already does `auth include sudo_local`; macOS ships only the
commented-out template, and `sudo_local` survives OS updates where editing
`sudo` itself does not.

``` bash
sudo tee /etc/pam.d/sudo_local >/dev/null <<'EOF'
auth       sufficient     pam_tid.so
EOF
sudo chmod 444 /etc/pam.d/sudo_local
```

> `pam_reattach` is not needed. The folklore dates from tmux servers that
> `setsid()` out of the Aqua session; tmux 3.7c keeps the audit session
> (`getaudit_addr` reports the same `asid` and `HAS_GRAPHIC_ACCESS` inside the
> server, and `LAContext.canEvaluatePolicy` returns true there). It would only
> matter for a server first spawned from an SSH login.

## Paseo
Runs from a patched private copy, `~/Applications/Paseo-Vibrancy.app`,
rebuilt by [`bin/paseo-repatch`](bin/paseo-repatch) whenever the stock app
updates. The script's docstring is the reference: what each patch does, why the
asar ones are length-preserving, and the frame-rate knobs that cut the
WindowServer CPU an agent turn costs from 40–50% to 10–15%. The `brew` function
re-runs it after cask upgrades; a beta taken through the in-app updater needs a
bare `paseo-repatch` by hand.

The Oxocarbon entry in Settings → Appearance is a plugin, not a patch:
[`paseo/plugins/oxocarbon`](paseo/plugins/oxocarbon). `paseo plugin ls` shows it
installed straight from this directory rather than a vendored copy, so an edit
here is the live plugin — `paseo plugin reload oxocarbon` picks it up, and the
app window needs reloading too when a client contribution changes. `install`
runs once per plugin ID and errors on a second attempt; `reload` is the
everyday command. Restore the type-only devDependencies with `npm install` in
that directory; `npm run typecheck` is what verifies a call against Paseo's own
types rather than the docs.

> Paseo derives a plugin theme's whole token set from eight colours, and not by
> name: `raised` becomes `surface1`, which fills panes and cards — in sidebar
> scope, the entire content pane. It is the brightness knob, and `background`
> is not. The mapping is written out in the plugin.

> Plan usage showing Claude as *Unavailable* while `claude auth status` says
> logged in means a stale `~/.claude/.credentials.json` is present. Claude Code
> keeps live credentials in the Keychain on macOS and never rewrites that file,
> but Paseo reads the file first and only falls back to the Keychain when it is
> absent — so an old file shadows a valid login with an expired token. Delete
> the file; the CLI is unaffected.

> Do not measure GPU load with `ioreg`'s `"Device Utilization %"`. It read
> 40–60% on this machine in a state where `sudo powermetrics --samplers
> gpu_power` reported ~92% idle residency and ~100 mW, and it sent three
> separate investigations here after the wrong process. `powermetrics` reads
> the frequency-state residency from the hardware and is the only number worth
> trusting; per-process CPU from `ps`/`top` is fine, and freezing a suspect
> with `kill -STOP` settles attribution faster than any counter.
