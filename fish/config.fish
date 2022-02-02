set fish_greeting ""

set -gx TERM xterm-256color

if status is-interactive
  # Commands to run in interactive sessions can go here
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
  # <<< conda initialize <<<
end

# theme
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# aliases
alias ls "l"
alias g "git"
alias rbrew='arch -x86_64 /usr/local/bin/brew'
alias rosetta="arch -x86_64"
alias py="python3"
alias tma "tmux attach-session || tmux new -s default"
alias tmd "tmux detach"

# config editor
command -qv nvim && alias vi nvim
set -gx EDITOR nvim

# config fish-exa
set -Ux EXA_STANDARD_OPTIONS --long --group --icons
set -Ux EXA_LA_OPTIONS --all
set -Ux EXA_LT_OPTIONS --all --tree --level 2

pyenv init - | source

# config ruby
fish_add_path /opt/homebrew/opt/ruby/bin
set -gx LDFLAGS "-L/opt/homebrew/opt/ruby/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/ruby/include"
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/ruby/lib/pkgconfig"

# config gem path, its actually just runs once but if it exists not appended.
fish_add_path (ruby -e 'print Gem.user_dir')/bin

