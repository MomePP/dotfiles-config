local M = {
    'hiphish/rainbow-delimiters.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-treesitter' },
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
