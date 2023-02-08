local M = {
    'echasnovski/mini.indentscope',
    event = { 'BufReadPre', 'BufNewFile' }
}

M.init = function()
    -- INFO: disable on some filetypes
    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'alpha', 'lazy', 'man', 'help', 'lspinfo', 'checkhealth', 'toggleterm', 'mason' },
        callback = function() vim.b.miniindentscope_disable = true end,
    })
end

M.opts = function()
    return {
        symbol = '│',
        draw = { animation = require('mini.indentscope').gen_animation.none() },
        options = { try_as_border = true },
    }
end

M.config = function(_, opts)
    require('mini.indentscope').setup(opts)
end

return M
