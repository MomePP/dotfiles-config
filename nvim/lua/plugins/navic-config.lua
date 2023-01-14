local M = {
    'SmiteshP/nvim-navic',
    event = 'BufReadPre'
}

M.config = function()
    require('nvim-navic').setup({
        separator = '  ',
        depth_limit = 6,
        highlight = true,
    })
end

return M
