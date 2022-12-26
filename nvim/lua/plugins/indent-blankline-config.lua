local M = {
    'lukas-reineke/indent-blankline.nvim',
    event = 'BufReadPre'
}

M.config = function()
    local blankline = require('indent_blankline')
    blankline.setup {
        -- char = '▏',
        -- context_char = '▏',
        use_treesitter = true,
        use_treesitter_scope = true,
        filetype_exclude = {
            'man',
            'checkhealth',
            'help',
            'lspinfo',
            'TelescopePrompt',
            'TelescopeResults',
        },
        buftype_exclude = {
            'terminal',
            'nofile',
        },
        -- show_current_context_start = true,
        show_tailing_blankline_indent = false,
        show_first_indent_level = false,
        show_current_context = true,
        indent_level = 4,
        max_indent_increase = 1,
    }
end

return M
