# MomePP's dotfiles
## Neovim
> Requires Neovim version 0.6.0 or Nightly

Runs `neovim-installer.sh` script to install neovim and deps
``` bash
./neovim-installer.sh
```
Currently, uses `impatient` plugin to cache lua config files.
This may results first times running failed to import `packer_compiled` file.

To fix this, try to install all the plugins and it will creating the missing file.
``` vim
" run this in vim command mode
:PackerSync
```
**Note:** This may need to restart neovim for a couple of times

## Fish shell
Does not have install script yet. But mainly install `fish` and `fisher`(packages manager)

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

