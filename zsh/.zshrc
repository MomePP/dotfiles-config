# Interactive shell config. Exported env and PATH live in .zprofile.

# -- completion ---------------------------------------------------------------
#
# compinit must run before carapace: carapace's zsh init calls `compdef`, which
# does not exist until the completion system is loaded. brew shellenv already
# put /opt/homebrew/share/zsh/site-functions on FPATH, so this alone picks up
# the 23 completions brew ships (_bat _eza _fd _gh _glab _delta _fnm _rustup …).
# The dump path is pinned: compinit defaults it next to the rc file, which for
# a $ZDOTDIR-based launch would drop a generated .zcompdump inside the tracked
# config dir.
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
mkdir -p "${_zcompdump:h}"
autoload -Uz compinit && compinit -d "$_zcompdump"
unset _zcompdump

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# carapace covers what brew's site-functions do not (lazygit, tmux, cargo) and
# bridges to fish/bash specs for the rest.
source <(carapace _carapace zsh)

# -- tool init ----------------------------------------------------------------
eval "$(starship init zsh)"

# --use-on-cd switches node per .nvmrc/.node-version on every cd. The nushell
# config only ever had this as a commented-out env_change hook.
eval "$(fnm env --use-on-cd --shell zsh)"

# Does more than the bare shims-on-PATH the nushell config had: also loads
# pyenv's own completions and defines the pyenv() wrapper that makes
# `pyenv shell <version>` work.
eval "$(pyenv init - zsh)"

# SHELL is pinned rather than inherited: bun picks the completion dialect from
# $SHELL and hard-errors on anything it does not recognise, which would break
# this file when sourced from a shell launched before `chsh` took effect.
source <(SHELL=zsh bun completions)

# -- history ------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY        # timestamp each entry
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE       # a leading space keeps a command out of history
setopt HIST_VERIFY             # expand !! into the buffer instead of running it

# -- options ------------------------------------------------------------------
setopt INTERACTIVE_COMMENTS
setopt AUTO_CD
setopt EXTENDED_GLOB
setopt NO_BEEP

# -- vi mode ------------------------------------------------------------------
bindkey -v
KEYTIMEOUT=1   # 10ms; the 0.4s default makes ESC feel broken

# Block cursor in insert, underscore in normal — same as the nushell
# cursor_shape config. Also reset to block on every new prompt, since a command
# that exits while in normal mode would otherwise leave the underscore behind.
function zle-keymap-select {
    case $KEYMAP in
        vicmd) printf '\e[4 q' ;;
        viins|main) printf '\e[2 q' ;;
    esac
}
zle -N zle-keymap-select
function zle-line-init { printf '\e[2 q' }
zle -N zle-line-init

# -- keybinds -----------------------------------------------------------------
#
# Ported from the nushell keybindings block. Bound in both keymaps (viins/vicmd)
# wherever the nushell binding listed both vi_insert and vi_normal.
autoload -Uz edit-command-line && zle -N edit-command-line

bindkey '^O' edit-command-line          # ctrl-o: edit buffer in $EDITOR
bindkey '^R' history-incremental-search-backward
bindkey '^A' beginning-of-line
bindkey '^W' backward-kill-word
bindkey '^H' backward-delete-char
bindkey '^[^?' backward-kill-word       # alt-backspace
bindkey '^P' up-line-or-history
bindkey '^T' down-line-or-history       # ctrl-t, matching the nushell binding
bindkey '^[[1;5D' backward-word         # ctrl-left
bindkey '^[[1;5C' forward-word          # ctrl-right
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

bindkey -M vicmd '^R' history-incremental-search-backward
bindkey -M vicmd '^O' edit-command-line
bindkey -M vicmd '^A' beginning-of-line

# -- plugins ------------------------------------------------------------------
#
# nushell had inline hints and syntax highlighting built in; zsh needs these two
# to reach parity. Guarded so a machine without them still gets a working shell:
#   brew install zsh-autosuggestions zsh-syntax-highlighting
_zsh_plugins=/opt/homebrew/share
if [[ -f $_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    # Right arrow takes the hint, as in nu — no bindkey needed, forward-char and
    # vi-forward-char are already in ZSH_AUTOSUGGEST_ACCEPT_WIDGETS. Binding the
    # key to autosuggest-accept directly would *break* plain rightward cursor
    # movement when no suggestion is showing.
    source $_zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
# Must be sourced last — it wraps every widget bound before it.
if [[ -f $_zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source $_zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
unset _zsh_plugins

# -- listing ------------------------------------------------------------------
#
# eza tuned to read like nushell's `ls` table: size, relative mtime, git status,
# name, under a header row. It cannot go all the way — eza has no option for the
# box borders or the `#` index column, those belong to nushell's renderer, not
# to a listing tool. Type is carried by the icon plus the --classify suffix
# (`/` dir, `*` executable, `@` symlink) instead of a column of its own.
#
# The l/la vs ll/lla split mirrors nushell's `ls` vs `ls -l`: the short pair
# drops permissions and owner, the long pair keeps them.
#
# --icons=always, never bare --icons: the flag takes an *optional* value and
# greedily swallows a following path, so `eza -l --icons .` is a parse error.
#
# Colours come from eza/theme.yml, which needs EZA_CONFIG_DIR exported — see
# the note in .zprofile.
_eza_nu='--long --header --time-style=relative --icons=always --git --classify=always'

# `ls` gets the same view as `l`: under nushell `ls` was already the table, so
# a bare grid here would be the odd one out. Reach the real binary with
# `command ls` or `\ls` when POSIX behaviour is actually wanted — note that
# eza reads `-h` as --header, not --human-readable, so `ls -lh` is not an error
# but does not mean what it does in coreutils.
alias ls="eza $_eza_nu --no-permissions --no-user"
alias l="eza $_eza_nu --no-permissions --no-user"
alias la="eza $_eza_nu --no-permissions --no-user --all"
alias ll="eza $_eza_nu --smart-group"
alias lla="eza $_eza_nu --smart-group --all"
alias lt="eza $_eza_nu --tree --level=2"
unset _eza_nu   # aliases expanded it at definition time; nothing needs it later

# -- aliases ------------------------------------------------------------------

alias c='clear'
alias vi='nvim'
alias lg='lazygit'
alias cat='bat'

alias rbrew='arch -x86_64 /usr/local/bin/brew'
alias rosetta='arch -x86_64'

alias py='python3'
alias python='python3'
alias pip='python3 -m pip'

alias tma='tmux new-session -A -s default'
alias tmd='tmux detach'
alias kssh='kitty +kitten ssh'

# -- functions ----------------------------------------------------------------
cx() {
    cd "$1" && ll
}

# Not every host has a terminfo entry for whatever we are running under; pin a
# universally-present one for the remote side only.
ssh() {
    TERM=xterm-256color command ssh "$@"
}

# the claude-code cask installs to a version-stamped path, and macOS TCC grants
# app-data access by absolute path — so re-point the stable ~/.local/bin/claude
# hardlink after every brew run. silent unless it actually relinks. the relink
# runs on the failure path too: a partly-failed `brew upgrade` may still have
# upgraded claude-code.
#
# espressif's clangd fork has no formula and no pio package, so nothing tracks
# its releases — fold it into the commands already used for exactly this, and
# mirror brew's own split: `update` reports what is available, `upgrade`
# installs it. only on those two subcommands, since each costs a GitHub API
# call and `brew --prefix` style invocations must stay cheap. both stay quiet
# when there is nothing to do; the `|| true` keeps a failed clangd install from
# masking the brew run that already succeeded.
brew() {
    local rc
    command brew "$@"
    rc=$?
    claude-relink
    (( rc == 0 )) || return $rc
    case "$1" in
        update)  esp-clangd-update --check ;;
        upgrade) esp-clangd-update --quiet || true ;;
    esac
}
