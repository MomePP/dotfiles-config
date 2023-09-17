local M = {
    'lukas-reineke/indent-blankline.nvim',
    branch = 'v3',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = 'nvim-treesitter'
}

M.config = function()
    local rainbow_highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
    }

    require('ibl').setup {
        indent = {
            char = '•',
            smart_indent_cap = true,
        },
        scope = {
            show_start = false,
            show_end = false,
            highlight = rainbow_highlight,
        }
    }

    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end

return M
