local M = {
    'SmiteshP/nvim-navic',
    event = 'BufReadPre'
}

M.config = function()
    -- set highlight for navic
    local navic_highlight = require('colorscheme').navic_highlight
    if navic_highlight then
        for group, colors in pairs(navic_highlight) do
            vim.api.nvim_set_hl(0, group, colors)
        end
    end

    local navic = require('nvim-navic')
    navic.setup({
        separator = '  ',
        depth_limit = 6,
        highlight = true,
    })
end

return M
