#!/bin/bash

# WARN: must have brew installed
brew install wget neovim lazygit git-flow ripgrep neovim-remote gotop

# NOTE: add neovim-remote config to default shell config (currently using fish)
# currently handles by using lazygit config -> the downside, it cannot use lazygit outside nvim
# echo -e "export VISUAL=\"nvr --remote-wait + 'set bufhidden=wipe'\"\n" >> ~/.config/fish/config.fish

# -- add edit and open commands for lazygit config if config not exists
lazygit_config=~/Library/Application\ Support/lazygit/config.yml
if [ ! -f "$lazygit_config" ]; then
  echo -e "os:\n\teditCommand: \"nvim\"\n\topenCommand: \"nvr -cc vsplit --remote +'set bufhidden=wipe' {{filename}}\"" >> ~/Library/Application\ Support/lazygit/config.yml
  echo "lazygit config added !"
fi

