# MomePP's dotfiles
## Neovim
> Requires Neovim version 0.6.0 or Nightly

Runs `requirement.sh` script to installs deps
``` bash
./requirements.sh
```
**Note** Currently, uses `impatient` plugin to cache lua config files.
This may results first times running failed to import `packer_compiled` file.

To fix this, try to install all the plugins and it will creating the missing file.
``` vim
:PackerSync
```
* may need to restart neovim for couple times

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

