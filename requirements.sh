#!/bin/bash

# WARN: must have brew installed
brew install wget neovim lazygit git-flow ripgrep neovim-remote gotop

# NOTE: extension installers list
# BUG: currently installer broken
# pip3 install ueberzug           # INFO: for image preview used by telescope-media-files
# brew install ffmpegthumbnailer  # INFO: for video preview used by telescope-media-files

# -- add neovim-remote config to default shell config (currently using fish)
# NOTE: currently handles by using lazygit config -> the downside, it cannot use lazygit outside nvim
# echo -e "export VISUAL=\"nvr --remote-wait + 'set bufhidden=wipe'\"\n" >> ~/.config/fish/config.fish

# -- add edit and open commands for lazygit config
echo -e "os:\n\teditCommand: \"nvim\"\n\topenCommand: \"nvr -cc vsplit --remote +'set bufhidden=wipe' {{filename}}\"" >> ~/Library/Application\ Support/lazygit/config.yml

