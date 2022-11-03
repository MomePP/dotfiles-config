local status_ok, illuminate = pcall(require, 'illuminate')
if not status_ok then return end

local colors = require('colorscheme').colorset

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
vim.api.nvim_set_hl(0, 'IlluminatedWordText', { bg = colors.bg1, bold = true, nocombine = true })
vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'IlluminatedWordText' })
vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'IlluminatedWordText' })
