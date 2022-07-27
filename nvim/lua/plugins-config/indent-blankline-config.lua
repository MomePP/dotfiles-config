local status_ok, blankline = pcall(require, 'indent_blankline')
if not status_ok then return end

blankline.setup {
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
        'lsp-installer',
        'TelescopePrompt',
        'TelescopeResults',
    },
    show_tailing_blankline_indent = false,
    show_first_indent_level = false,
    show_current_context = true,
    -- show_current_context_start = true,
}
