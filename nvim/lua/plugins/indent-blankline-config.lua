local M = {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        {
            'echasnovski/mini.indentscope',
            opts = {
                symbol = '•',
            },
        }
    }
}

M.opts = {
    indent = {
        char = '•',
        smart_indent_cap = true,
    },
    scope = {
        enabled = false,
    }
}

M.config = function(_, opts)
    require('ibl').setup(opts)

    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end

return M
