set fish_greeting ""

set -gx TERM xterm-256color

if status is-interactive
  # Commands to run in interactive sessions can go here
  # >>> conda initialize >>>
  # !! Contents within this block are managed by 'conda init' !!
  eval /opt/homebrew/Caskroom/miniforge/base/bin/conda "shell.fish" "hook" $argv | source
  # <<< conda initialize <<<
end

# config homebrew path
fish_add_path /opt/homebrew/bin

# add platformio env path
fish_add_path /Users/momeppkt/.platformio/penv/bin

# set locale terminal
set -x LC_CTYPE "en_US.UTF-8"
set -x LC_ALL "en_US.UTF-8"
set -x LC_TERMINAL "iTerm2"

# theme
set -g fish_prompt_pwd_dir_length 1
set -g theme_display_user yes
set -g theme_hide_hostname no
set -g theme_hostname always

# start pyenv
if status is-interactive
    set -Ux PYENV_ROOT $HOME/.pyenv
    fish_add_path $PYENV_ROOT/bin
end
status is-interactive; and pyenv init - | source
status is-login; and pyenv init --path | source

# config editor
command -qv nvim && alias vi nvim
set -gx EDITOR nvim

# config fish-exa
set -Ux EXA_STANDARD_OPTIONS --long --group --icons
set -Ux EXA_LA_OPTIONS --all
set -Ux EXA_LT_OPTIONS --all --tree --level 2

# config ruby
fish_add_path /opt/homebrew/opt/ruby/bin
set -gx LDFLAGS "-L/opt/homebrew/opt/ruby/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/ruby/include"
set -gx PKG_CONFIG_PATH "/opt/homebrew/opt/ruby/lib/pkgconfig"

# config gem path, its actually just runs once but if it exists not appended.
fish_add_path (ruby -e 'print Gem.user_dir')/bin

# config rust tools for esp32
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.espressif/tools/xtensa-esp32-elf-clang/esp-13.0.0-20211203-aarch64-apple-darwin/bin/
set -x LIBCLANG_PATH "/Users/momeppkt/.espressif/tools/xtensa-esp32-elf-clang/esp-13.0.0-20211203-aarch64-apple-darwin/lib/"
set -x PIP_USER no
set -x IDF_PATH "$HOME/Developments/toolchains/esp-idf"
set -x MENUCONFIG_STYLE "monochrome"
alias get-idf ". $HOME/Developments/toolchains/esp-idf/export.fish"

# config llvm arm64
fish_add_path /opt/homebrew/opt/llvm/bin
set -gx LDFLAGS "-L/opt/homebrew/opt/llvm/lib"
set -gx CPPFLAGS "-I/opt/homebrew/opt/llvm/include"

#config llvm x86_64
# fish_add_path /usr/local/opt/llvm/bin
# set -gx LDFLAGS "-L/usr/local/opt/llvm/lib"
# set -gx CPPFLAGS "-I/usr/local/opt/llvm/include"

# set path for commandline tools
fish_add_path /Library/Developer/CommandLineTools/usr/bin
set -Ux SDKROOT /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk

# aliases
alias ls "l"
alias g "git"
alias rbrew='arch -x86_64 /usr/local/bin/brew'
alias rosetta="arch -x86_64"
alias py="python3"
alias tma "tmux attach-session || tmux new -s default"
alias tmd "tmux detach"
alias python "$(pyenv which python)"
alias pip "$(pyenv which pip)"

