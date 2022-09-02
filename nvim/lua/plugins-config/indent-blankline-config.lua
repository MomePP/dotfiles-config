local status_ok, blankline = pcall(require, 'indent_blankline')
if not status_ok then return end

blankline.setup {
    -- char = '▏',
    -- context_char = '▏',
    use_treesitter = true,
    use_treesitter_scope = false,
    filetype_exclude = {
        'man',
        'checkhealth',
        '',
        'help',
        'terminal',
        'packer',
        'lspinfo',
        'lsp-installer',
        'TelescopePrompt',
        'TelescopeResults',
    },
    show_tailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    -- show_current_context_start = true,
}

-- vim.api.nvim_set_hl(0, 'IndentBlanklineContextStart', { sp = '#ff7800', underline = true })
-- vim.api.nvim_set_hl(0, 'IndentBlanklineContextStart', { fg = '#ff7800', nocombine = true })
vim.api.nvim_set_hl(0, 'IndentBlanklineContextChar', { fg = '#ff7800', nocombine = true })
