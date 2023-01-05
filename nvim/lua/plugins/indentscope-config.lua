local M = {
    'echasnovski/mini.indentscope',
    event = 'BufReadPre',
}

M.config = function()
    local indentscope = require('mini.indentscope')

    -- INFO: disable on some filetypes
    vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'alpha', 'lazy', 'man', 'help', 'lspinfo', 'checkhealth', 'toggleterm' },
        callback = function()
            vim.b.miniindentscope_disable = true
        end,
    })

    indentscope.setup({
        symbol = '│',
        draw = { animation = indentscope.gen_animation.none() },
        options = { try_as_border = true },
    })
end

return M
