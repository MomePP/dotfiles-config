# Login-shell environment. Runs once per login shell, before .zshrc.
#
# Everything here is exported state (PATH, env vars). Interactive-only setup —
# completions, prompt, aliases, keybinds — lives in .zshrc.

# Homebrew first: it seeds HOMEBREW_PREFIX/CELLAR/REPOSITORY, INFOPATH, FPATH,
# and the /opt/homebrew half of PATH that everything below prepends onto.
eval "$(/opt/homebrew/bin/brew shellenv)"

# -- PATH ---------------------------------------------------------------------
#
# Listed low-to-high precedence so the resulting order matches what nushell's
# `path add` produced. pyenv shims and the fnm multishell dir are NOT here —
# their inits in .zshrc prepend them, which is how both tools want it.
#
# rustup is spelled out rather than `$(brew --prefix rustup)`: the opt/ path is
# a stable symlink, and shelling out to brew on every login costs ~200ms.
path=(
    "$HOME/.local/share/nvim/mason/bin"
    "$HOME/.bun/bin"
    /opt/homebrew/opt/rustup/bin
    "${CARGO_HOME:-$HOME/.cargo}/bin"
    "$HOME/.local/bin"
    $path
)
typeset -U path   # dedupe, keep first occurrence

# -- environment --------------------------------------------------------------
export XDG_CONFIG_HOME="$HOME/.config"

export EDITOR='nvim'
export VISUAL='nvim'

# render manpages through bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

export SDKROOT='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'

# carapace falls back to these shells' completion specs for commands it has no
# native spec for (lazygit, tmux, cargo — none of which ship a zsh completion).
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'

# Must be set explicitly. eza(1) claims this "defaults to $XDG_CONFIG_HOME/eza
# or $HOME/.config/eza", but 0.23.5 does not actually look there — the theme is
# silently ignored unless the variable is present, even when it names the exact
# path the man page describes.
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
