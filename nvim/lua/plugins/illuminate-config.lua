local M = {
    'RRethy/vim-illuminate',
    event = 'BufReadPost'
}

M.config = function()
    local illuminate = require('illuminate')
    illuminate.configure({
        delay = 200,
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
    local colors = require('colorscheme').colorset
    vim.api.nvim_set_hl(0, 'IlluminatedWordText', { bg = colors.bg1, bold = true, nocombine = true })
    vim.api.nvim_set_hl(0, 'IlluminatedWordRead', { link = 'IlluminatedWordText' })
    vim.api.nvim_set_hl(0, 'IlluminatedWordWrite', { link = 'IlluminatedWordText' })
end

return M
