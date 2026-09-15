#!/bin/bash

# WARN: must have brew installed
brew install wget lazygit git-flow-next git-delta ripgrep fd eza fnm neovim gh bat pyenv tmux starship aerospace tree-sitter-cli carapace
# Inline hints and syntax highlighting are the two things zsh has no built-in
# equivalent for. .zshrc sources them behind an existence check, so a machine
# without them still gets a working shell.
brew install zsh-autosuggestions zsh-syntax-highlighting
# brew install opencode
# brew install --cask ghostty kitty

config_path=~/.config

# INFO: -- resolve where this repo actually lives
#
# The repo can be cloned straight onto the install target
# (`git clone … ~/.config`), in which case source and destination are the same
# path: `install_config_dir` would `rm -rf` the tracked directory and then `cp`
# something that no longer exists, destroying the config instead of installing
# it. Resolve both sides up front and skip every item that is already in place.
repo_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$config_path"
config_path="$(cd "$config_path" && pwd -P)"
if [[ "$repo_path" == "$config_path" ]]; then
    echo "repo is ~/.config itself: config dirs/files stay in place, only external links are created"
fi

# INFO: -- helper to install a config directory
install_config_dir() {
    local name="$1"
    local source="$repo_path/$name"
    local target="$config_path/$name"
    local update="y"
    local found=false
    if [ "$source" = "$target" ]; then
        echo "kept $name config in place.."
        return
    fi
    if [ ! -d "$source" ]; then
        echo "missing $name in repo, skipped.."
        return
    fi
    if [ -d "$target" ]; then
        found=true
        read -p "found exist $name config.. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm -rf "$target"
        fi
        cp -r "$source" "$config_path"
        echo "added $name config !"
    else
        echo "skipped $name config.."
    fi
}

# INFO: -- helper to install a config file
install_config_file() {
    local name="$1"
    local source="$repo_path/$name"
    local target="$config_path/$name"
    local update="y"
    local found=false
    if [ "$source" = "$target" ]; then
        echo "kept $name config in place.."
        return
    fi
    if [ ! -f "$source" ]; then
        echo "missing $name in repo, skipped.."
        return
    fi
    if [ -f "$target" ]; then
        found=true
        read -p "found exist $name config.. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm "$target"
        fi
        cp "$source" "$config_path"
        echo "added $name config !"
    else
        echo "skipped $name config.."
    fi
}

# INFO: -- helper to symlink a config file into a location outside ~/.config
# claude-hud refuses a symlinked config: since 0.8.0 its loader lstats the file
# and ignores anything that is not a regular file, so a link silently drops the
# whole config back to defaults. Copy instead — nothing else writes that file,
# so the copy only drifts when you change it deliberately.
copy_config() {
    local source="$config_path/$1" # relative to $config_path
    local target="$2"              # absolute path to create
    local update="y"
    if [ ! -f "$source" ]; then
        echo "missing $1 in ~/.config, skipped $(basename "$target").."
        return
    fi
    if [[ -e "$target" ]]; then
        read -p "found exist $(basename "$target") .. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        echo "copied $target !"
    else
        echo "skipped $(basename "$target").."
    fi
}

# A pre-existing target may be a real directory, not just a file or a stale
# link: Claude Code creates ~/.claude/skills itself. `ln -s` into a surviving
# directory silently nests the link one level down, so the target is cleared
# (after the prompt) whatever its type.
symlink_config() {
    local source="$config_path/$1" # relative to $config_path
    local target="$2"              # absolute path to create
    local update="y"
    local found=false
    if [ ! -e "$source" ]; then
        echo "missing $1 in ~/.config, skipped $(basename "$target").."
        return
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        found=true
        read -p "found exist $(basename "$target") .. overwrite (y) or (n) ? : " update
    fi
    if [ "$update" = "y" ]; then
        if $found; then
            rm -rf "$target" # remove old symlink, file or directory
        fi
        mkdir -p "$(dirname "$target")"
        ln -s "$source" "$target"
        echo "linked $target !"
    else
        echo "skipped $(basename "$target").."
    fi
}

# INFO: -- install config directories
config_dirs=(nvim aerospace aerospace-swipe bat bin carapace claude-code delta eza gh-dash ghostty git homebrew kitty lazygit opencode superset tmux zsh)
for dir in "${config_dirs[@]}"; do
    install_config_dir "$dir"
done

# INFO: -- install config files
#
# .gitconfig is installed here rather than linked straight out of the clone:
# the ~/.gitconfig link below points into ~/.config, so the file has to exist
# there first or a clone living anywhere else leaves a dangling link.
install_config_file "starship.toml"
install_config_file ".gitconfig"

# INFO: -- symlink gitconfig file (git only reads it from $HOME)
symlink_config ".gitconfig" ~/.gitconfig

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

# claude-hud's display config. Copied, not linked — see copy_config above. It
# lives beside plugins/cache rather than inside it, so it survives every plugin
# update; only the statusLine path in settings.json is version-stamped, and
# that one is deliberately untracked (see claude-settings-sync IGNORED_KEYS).
copy_config "claude-code/claude-hud/config.json" ~/.claude/plugins/claude-hud/config.json

# The whole skills dir is linked, so a new hand-written skill needs no extra
# wiring here. Claude Code writes its own `learned/` skills into the same tree;
# that path is gitignored in claude-code/.gitignore rather than kept out by
# linking each skill separately.
symlink_config "claude-code/skills" ~/.claude/skills

# esp-clangd-update is called bare by the `brew` wrapper in zsh/.zshrc,
# and ~/.config/bin is not on PATH — so it needs the same ~/.local/bin symlink
# or every `brew update` on a fresh machine ends in "command not found".
symlink_config "bin/esp-clangd-update" ~/.local/bin/esp-clangd-update

# superset-repatch is called bare by the same `brew` wrapper, for the same
# reason. It rebuilds ~/Applications/Superset-transparent.app from the freshly
# upgraded /Applications/Superset.app, since a cask upgrade drops the
# transparency patches, the asar-integrity hash and the ad-hoc signature.
symlink_config "bin/superset-repatch" ~/.local/bin/superset-repatch

# paseo-repatch is the same idea for Paseo, and needs the symlink for the same
# reason. It also gets run by hand between cask upgrades: Paseo's in-app
# electron-updater replaces /Applications/Paseo.app without telling brew, so on
# the beta channel the wrapper never fires and the rebuild is manual.
symlink_config "bin/paseo-repatch" ~/.local/bin/paseo-repatch

# claude-settings-sync reports drift between ~/.claude/settings.json and the
# copy tracked here. They cannot be symlinked: Superset rewrites the live file
# on every app start, so the tracked copy is a template and deliberate settings
# have to be carried across by hand.
symlink_config "bin/claude-settings-sync" ~/.local/bin/claude-settings-sync

# NOTE: the SessionStart hooks in settings.json are NOT tracked here.
# ~/.claude/hooks/context-mode-cache-heal.mjs is vendor-managed — the tool
# redeploys and re-registers its own hook, so it self-heals on a fresh machine.
# Tracking it would only mirror vendor output into this repo on every update.

# INFO: -- Claude reads the opencode config dir; symlink rather than duplicate it
symlink_config "opencode" "$config_path/Claude"
