# MomePP's dotfiles
> Requires `Homebrew` to be installed

## Neovim
<img width="2536" alt="image" src="https://github.com/MomePP/dotfiles-config/assets/13793017/8df85204-80f9-460c-8a38-081a5a7bf3a5">

Runs `neovim-installer.sh` script to install neovim with MomePP's configuration.
``` bash
./neovim-installer.sh
```

#### Keybindings
Most of the keybindings can be modified in [keymaps.lua](nvim/lua/config/keymaps.lua).

#### Plugins
All the installed plugins are listed in [plugins/init.lua](nvim/lua/plugins/init.lua) or [plugins/](nvim/lua/plugins/)

## Fish shell
Need to install `fish` and `fisher`(packages manager)

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
Needs to install `tmux` and `tmp`(tmux plugins manager)

Already configured with following keybindings
- **Session** - follow by uppercase-letter
- **Window** - follow by Ctrl-key to hold
- **Pane** - follow by lowercase-letter

|| Session | Window | Pane |
|--- | --- | --- | --- |
|new  | `<prefix>N` | `<prefix><C-n>` | `<prefix>n` |
|next | `<prefix>J` or `<prefix>O` | `<prefix><C-j>` or `<prefix><C-o>` | `<prefix>j` or `<prefix>o` |
|previous | `<prefix>K` | `<prefix><C-k>` | `<prefix>k` |
|kill | `<prefix>X` | `<prefix><C-x>` | `<prefix>x` |

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


## fyabai : window tilling manager
Using `yabai` forked by `FelixKratz`

To remove old installed `yabai` : [issue-comment](https://github.com/FelixKratz/yabai/issues/10#issuecomment-1374409628)
``` bash
brew services stop yabai
brew uninstall yabai
killall yabai
brew tap FelixKratz/formulae
brew install fyabai --head
sudo yabai --uninstall-sa # don't forgot to unload old sa
sudo yabai --load-sa
brew services start fyabai
```
