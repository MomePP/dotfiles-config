local M = {}

M.defaults = {
    icons = {
        diagnostics = {
            Error = ' ',
            Warn = ' ',
            Hint = '󰄮 ',
            Info = ' ',
        },
        git = {
            added = ' ',
            modified = ' ',
            removed = ' ',
        },
        cmp = {
            kinds = {
                Array = '',
                Boolean = '',
                Class = 'ﴯ',
                Color = '',
                Constant = '',
                Constructor = '',
                Enum = '',
                EnumMember = '',
                Event = '',
                Field = 'ﰠ',
                File = '',
                Folder = '',
                Function = '',
                Interface = '',
                Key = '',
                Keyword = '',
                Method = '',
                Module = '',
                Namespace = '',
                Null = 'ﳠ',
                Number = '',
                Object = '',
                Operator = '',
                Package = '',
                Property = 'ﰠ',
                Reference = '',
                Snippet = '',
                String = '',
                Struct = 'פּ',
                Text = '',
                TypeParameter = '',
                Variable = '',
                Value = '',
                Unit = '塞',
            },
            source_format = '    '
        },
        lualine = {
            lsp = '',
            git = '',
            session = '',
        },
    },
    float_border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
}

M.setup = function()
    if vim.fn.argc( -1) == 0 then
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
