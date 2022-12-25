-- INFO: checking does nvim runs from `vscode-neovim` or not
if not vim.g.vscode then
    -- nvim setting config
    require 'options'

    -- plugin config
    require 'lazyconfig'
    require 'colorscheme'

    -- apply user config
    vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
            require 'autocommands'
            require 'keymaps'.setup()
        end,
    })
else
    vim.cmd('source $HOME/.config/nvim/vscode/init.vim')
end
