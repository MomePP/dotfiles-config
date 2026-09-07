# MomePP's dotfiles
> Requires `Homebrew` to be installed

## Neovim
<img width="1672" alt="Image" src="https://github.com/user-attachments/assets/4031c96c-a562-4d4f-8946-9565a7aff63f" />

Runs `neovim-installer.sh` script to install neovim with MomePP's configuration.
``` bash
./neovim-installer.sh
```

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

## Fish shell
Requires `fish` and `fisher`(packages manager)

[**`fish`**](https://fishshell.com/)
``` bash
brew install fish   # install fish shell
chsh -s /bin/fish   # set default shell to fish
```

[**`fisher`**](https://github.com/jorgebucaran/fisher)
``` bash
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher   # install fisher
fisher update   # install all listed plugins in `fish_plugins`
```

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

## SKHD
update service plist file to runs skhd using `/bin/bash`

`~/Library/LaunchAgents/com.koekeishiya.skhd.plist`

- Add `SHELL` key to env dict
    ``` xml
        <key>SHELL</key>
        <string>/bin/bash</string>
    ```
