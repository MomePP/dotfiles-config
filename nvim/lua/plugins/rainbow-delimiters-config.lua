local M = {
    'hiphish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'rainbow-delimiters.setup'
}

M.opts = {
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-blocks',
    },
}

return M
