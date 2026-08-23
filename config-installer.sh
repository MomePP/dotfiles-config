#!/bin/bash

# WARN: must have brew installed
brew install wget lazygit git-flow-avh git-delta ripgrep fd eza fnm neovim gh bat pyenv tmux starship aerospace tree-sitter-cli carapace
# Inline hints and syntax highlighting are the two things zsh has no built-in
# equivalent for. .zshrc sources them behind an existence check, so a machine
# without them still gets a working shell.
brew install zsh-autosuggestions zsh-syntax-highlighting
brew install opencode
# brew install --cask ghostty kitty

config_path=~/.config

# INFO: -- helper to install a config directory
install_config_dir() {
    local name="$1"
    local update="y"
    local found=false
    if [ -d "$config_path/$name" ]; then
        found=true
        read -p "found exist $name config.. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm -rf "$config_path/$name"
        fi
        cp -r "$name" "$config_path"
        echo "added $name config !"
    else
        echo "skipped $name config.."
    fi
}

# INFO: -- helper to install a config file
install_config_file() {
    local name="$1"
    local update="y"
    local found=false
    if [ -f "$config_path/$name" ]; then
        found=true
        read -p "found exist $name config.. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm "$config_path/$name"
        fi
        cp "$name" "$config_path"
        echo "added $name config !"
    else
        echo "skipped $name config.."
    fi
}

# INFO: -- helper to symlink a config file into a location outside ~/.config
symlink_config() {
    local source="$1" # relative to $config_path
    local target="$2" # absolute path to create
    local update="y"
    local found=false
    if [[ -f "$target" || -L "$target" ]]; then
        found=true
        read -p "found exist $(basename "$target") .. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm "$target" # remove old symlink or old config file
        fi
        mkdir -p "$(dirname "$target")"
        ln -s "${config_path}/${source}" "$target"
        echo "linked $target !"
    else
        echo "skipped $(basename "$target").."
    fi
}

# INFO: -- install config directories
config_dirs=(nvim aerospace aerospace-swipe bat bin carapace claude-code delta eza gh-dash ghostty git herdr homebrew kitty lazygit opencode superset tmux zsh)
for dir in "${config_dirs[@]}"; do
    install_config_dir "$dir"
done

# INFO: -- install config files
install_config_file "starship.toml"

# INFO: -- symlink gitconfig file
gitconfig=~/.gitconfig
update_gitconfig="y"
found_gitconfig=false
if [[ -f "$gitconfig" || -L "$gitconfig" ]]; then
    found_gitconfig=true
    read -p "found exist gitconfig file.. overwrite (y) or (n) ? : " update_gitconfig
fi
if [ "$update_gitconfig" = "y" ]; then
    if $found_gitconfig; then
        rm "$gitconfig" # remove old symlink or old config file
    fi
    ln -s "${config_path}/.gitconfig" "$gitconfig"
    echo "update gitconfig !"
else
    echo "skipped gitconfig.."
fi

# INFO: -- symlink the zsh rc files
#
# zsh only reads these two from $HOME (or $ZDOTDIR, which we do not set), so
# they cannot live under ~/.config on their own. .zprofile carries PATH and
# exported env; .zshrc carries everything interactive.
symlink_config "zsh/.zprofile" ~/.zprofile
symlink_config "zsh/.zshrc" ~/.zshrc

# INFO: -- symlink claude code settings + the caskroom relink helper
#
# claude-relink keeps ~/.local/bin/claude hardlinked to the current cask
# binary. macOS TCC grants app-data access by absolute path, and the cask
# installs to a version-stamped dir, so without a stable path every
# `brew upgrade` re-triggers "Data Access Blocked". The Stop hook in
# settings.json runs the relink; both must be present for it to work.
symlink_config "claude-code/settings.json" ~/.claude/settings.json
symlink_config "claude-code/CLAUDE.md" ~/.claude/CLAUDE.md
symlink_config "bin/claude-relink" ~/.local/bin/claude-relink

# The whole skills dir is linked, so a new hand-written skill needs no extra
# wiring here. Claude Code writes its own `learned/` skills into the same tree;
# that path is gitignored in claude-code/.gitignore rather than kept out by
# linking each skill separately.
symlink_config "claude-code/skills" ~/.claude/skills

# esp-clangd-update is called bare by the `brew` wrapper in zsh/.zshrc,
# and ~/.config/bin is not on PATH — so it needs the same ~/.local/bin symlink
# or every `brew update` on a fresh machine ends in "command not found".
symlink_config "bin/esp-clangd-update" ~/.local/bin/esp-clangd-update

# NOTE: the SessionStart hooks in settings.json are NOT tracked here.
# ~/.claude/hooks/context-mode-cache-heal.mjs and herdr-agent-state.sh are
# vendor-managed — each tool redeploys and re-registers its own hook, so they
# self-heal on a fresh machine. Tracking them would only mirror vendor output
# into this repo on every plugin update.

# INFO: -- Claude reads the opencode config dir; symlink rather than duplicate it
symlink_config "opencode" "$config_path/Claude"
