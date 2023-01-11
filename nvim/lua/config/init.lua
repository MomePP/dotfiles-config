local M = {}

M.icons = {
    diagnostics = {
        Error = ' ',
        Warn = ' ',
        Hint = ' ',
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
        navic = ' ',
        lsp = '',
        git = '',
        session = '',
    },
}

M.setup = function()
    require 'config.options'

    -- setup autocommands to load user opts with VeryLazy event
    vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
            require 'config.autocommands'
            require 'config.keymaps'.setup()
        end,
    })
end

return M
