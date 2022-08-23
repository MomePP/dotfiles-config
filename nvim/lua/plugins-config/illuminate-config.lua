local status_ok, illuminate = pcall(require, 'illuminate')
if not status_ok then return end

illuminate.configure({
    filetypes_denylist = {
        'dirvish',
        'fugitive',
        'man',
        'checkhealth',
        'help',
        'terminal',
        'packer',
        'lspinfo',
        'lsp-installer',
        'TelescopePrompt',
        'TelescopeResults',
    },
})

-- override vim-illuminate highlight
vim.api.nvim_set_hl(0, 'IlluminatedWordText', { link = 'Visual' })
vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'Visual' })
vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'Visual' })
