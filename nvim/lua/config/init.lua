local M = {}

M.defaults = {
    icons = {
        diagnostics = {
            error = ' ',
            warn = ' ',
            hint = '󰄮 ',
            info = ' ',
        },
        git = {
            added = ' ',
            modified = ' ',
            removed = ' ',
        },
        lualine = {
            lsp = '󰂼',
            git = '',
            session = '',
            navic_separator = '  ',
        },
    },
    float_border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

M.setup = function()
    if vim.fn.argc(-1) == 0 then
        -- setup autocommands to load user opts with VeryLazy event
        vim.api.nvim_create_autocmd('User', {
            group = vim.api.nvim_create_augroup('UserConfig', { clear = true }),
            pattern = 'VeryLazy',
            callback = function()
                require 'config.autocommands'
                require 'config.keymaps'.setup()
            end,
        })
    else
        require 'config.autocommands'
        require 'config.keymaps'.setup()

        -- loads `telescope-file-browser` to handles in case of directory args
        require('lazy').load({ plugins = { 'telescope.nvim' } })
    end
end

M.did_init = false
M.init = function()
    if not M.did_init then
        M.did_init = true

        require 'config.options'
        require 'lazy-config'
    end
end

return M
