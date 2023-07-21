local M = {
    'hiphish/rainbow-delimiters.nvim',
}

M.config = function()
    vim.g.rainbow_delimiters = {
        query = {
            [''] = 'rainbow-delimiters',
            lua = 'rainbow-blocks',
        },
    }
end

return M
