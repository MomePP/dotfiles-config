-- INFO: checking does nvim runs from `vscode-neovim` or not
if not vim.g.vscode then
    print('start from native neovim !!')
    -- nvim setting configs
    require 'settings'
    local impatient_status, impatient = pcall(require, 'impatient')
    -- if impatient_status then impatient.enable_profile() end

    -- install plugins
    require 'plugins'
    require 'plugins-config'

    -- apply colorscheme
    require 'colorscheme'

    -- key mappings
    require 'keymappings'

    -- setup lsp server
    require 'lsp-config'
else
    print('start from vscode !!')
    vim.cmd("source $HOME/.config/nvim/vscode/init.vim")
end
