local M = {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
    }
}

M.opts = {
    enable = true,
    max_lines = 5,
    line_numbers = true,
}

return M
