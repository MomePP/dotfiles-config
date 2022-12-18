local status_ok, blankline = pcall(require, 'indent_blankline')
if not status_ok then return end

local colors = require('colorscheme').colorset

blankline.setup {
    -- char = '▏',
    -- context_char = '▏',
    use_treesitter = true,
    use_treesitter_scope = true,
    filetype_exclude = {
        'man',
        'checkhealth',
        '',
        'help',
        'terminal',
        'packer',
        'lspinfo',
        'TelescopePrompt',
        'TelescopeResults',
    },
    -- show_current_context_start = true,
    show_tailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    indent_level = 4,
    max_indent_increase = 1,
}

-- vim.api.nvim_set_hl(0, 'IndentBlanklineContextStart', { sp = colors.orange, underline = true })
-- vim.api.nvim_set_hl(0, 'IndentBlanklineContextStart', { fg = colors.orange, nocombine = true })
vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', { fg = colors.orange, nocombine = true })
