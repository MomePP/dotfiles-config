local M = {
    'nvim-treesitter/nvim-treesitter-context',
    event = { 'BufReadPost', 'BufNewFile' },
}

M.opts = {
    enable = true,
    max_lines = 5,
    line_numbers = true,
}

return M
