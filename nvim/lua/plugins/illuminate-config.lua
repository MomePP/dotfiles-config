local illuminate_keymap = require('config.keymaps').illuminate

local M = {
    'RRethy/vim-illuminate',
    event = { 'BufReadPost', 'BufNewFile' }
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

    vim.api.nvim_create_autocmd('FileType', {
        callback = function()
            local buffer = vim.api.nvim_get_current_buf()
            pcall(vim.keymap.del, 'n', illuminate_keymap.next, { buffer = buffer })
            pcall(vim.keymap.del, 'n', illuminate_keymap.prev, { buffer = buffer })
        end,
    })
end

M.keys = {
    { illuminate_keymap.next, function() require('illuminate').goto_next_reference(false) end, desc = 'Next Reference', },
    { illuminate_keymap.prev, function() require('illuminate').goto_prev_reference(false) end, desc = 'Prev Reference' },
}

return M
