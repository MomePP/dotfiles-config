local M = {
    'SmiteshP/nvim-navic',
    event = 'BufReadPre'
}

M.opts = {
    separator = '  ',
    depth_limit = 6,
    highlight = true,
}

return M
