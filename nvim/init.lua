-- INFO: checking does nvim runs from `vscode-neovim` or not
if not vim.g.vscode then
    print('start from native neovim !!')
    -- nvim setting configs
    pcall(require, 'settings')
    local impatient_status, impatient = pcall(require, 'impatient')
    -- if impatient_status then impatient.enable_profile() end

    -- install plugins
    pcall(require, 'plugins')

    -- apply colorscheme
    pcall(require, 'colorscheme')

    -- key mappings
    pcall(require, 'keymappings')

    -- setup lsp server
    pcall(require, 'lsp-config')

    -- plugin configs
    pcall(require, 'plugins-config')
else
    print('start from vscode !!')
    vim.cmd("source ~/.config/nvim/vscode/keymappings.vim")
end
