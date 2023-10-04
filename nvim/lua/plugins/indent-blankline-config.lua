local M = {
    'lukas-reineke/indent-blankline.nvim',
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

    local included_scope = {
        node_type = {
            lua = {
                'chunk',
                'do_statement',
                'while_statement',
                'repeat_statement',
                'if_statement',
                'for_statement',
                'function_declaration',
                'function_definition',
                'table_constructor',
                'assignment_statement',
            },
            typescript = {
                'statement_block',
                'function',
                'arrow_function',
                'function_declaration',
                'method_definition',
                'for_statement',
                'for_in_statement',
                'catch_clause',
                'object_pattern',
                'arguments',
                'switch_case',
                'switch_statement',
                'switch_default',
                'object',
                'object_type',
                'ternary_expression',
            },
        }
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
            include = included_scope,
        },
        debounce = 500,
    }

    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end

return M
