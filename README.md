# MomePP's dotfiles
> Requires `Homebrew` to be installed

## Neovim
Runs `neovim-installer.sh` script to install neovim with MomePP's configuration.
``` bash
./neovim-installer.sh
```
Currently, uses `impatient` plugin to cache lua config files.
This may result first times running failed to import `packer_compiled` file.

To fix this, try to install all the plugins by run following command in neovim.
``` vim
" run this in vim command mode
:PackerSync
```
**Note:** This may need to restart neovim for a couple of times

### Keybindings
Most of the shortcuts can be modified in [keymappings](nvim/lua/keymappings.lua). Only LSP related shortcuts can be found in [lsp-handler](nvim/lua/lsp-config/lsp-handler.lua).

### Plugins
All the installed plugins are listed [Here](nvim/lua/plugins.lua)

---

## Fish shell
Does not have installing script yet. But mainly install `fish` and `fisher`(packages manager)

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

---
