-- INFO: checking does nvim runs from `vscode-neovim` or not
if not vim.g.vscode then
    -- init options and load plugins
    require 'config'.init()

    -- loads user config
    require 'config'.setup()
else
    -- loads keymap for neovim-vscode
    vim.cmd 'source $HOME/.config/nvim/vscode/init.vim'
end
