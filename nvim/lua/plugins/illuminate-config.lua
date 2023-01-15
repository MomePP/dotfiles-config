local M = {
    'RRethy/vim-illuminate',
    event = 'BufReadPost'
}

M.opts = {
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
}

M.config = function(_, opts)
    require('illuminate').configure(opts)
end

return M
