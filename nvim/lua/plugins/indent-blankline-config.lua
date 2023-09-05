local M = {
    'lukas-reineke/indent-blankline.nvim',
    branch = 'v3',
    event = { 'BufReadPost', 'BufNewFile' },
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
            char = '│',
            smart_indent_cap = true,
        },
        scope = {
            show_start = false,
            highlight = rainbow_highlight,
        },
        whitespace = {
            remove_blankline_trail = true,
        }
    }

    local hooks = require 'ibl.hooks'
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
end

return M
