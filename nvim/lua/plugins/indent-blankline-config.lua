local M = {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
}

M.opts = function()
    local highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterBlue',
        'RainbowDelimiterCyan',
        'RainbowDelimiterGreen',
        'RainbowDelimiterYellow',
        'RainbowDelimiterOrange',
        'RainbowDelimiterViolet',
    }

    return {
        indent = {
            char = '•',
            smart_indent_cap = true,
        },
        scope = {
            enabled = true,
            show_start = false,
            show_end = false,
            highlight = highlight,
        },
        debounce = 300
    }
end

M.config = function(_, opts)
    require('ibl').setup(opts)

    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
end

return M
