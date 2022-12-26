local M = {
    'SmiteshP/nvim-navic',
    event = 'BufReadPre'
}

M.config = function()
    local navic = require('nvim-navic')
    navic.setup({
        separator = '  ',
        depth_limit = 6,
        highlight = true,
    })
end

return M
