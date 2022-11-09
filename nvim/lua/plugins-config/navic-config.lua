local status_ok, navic = pcall(require, 'nvim-navic')
if not status_ok then return end

-- set highlight for navic
local navic_highlight = require('colorscheme').navic_highlight
if navic_highlight then
    for group, colors in pairs(navic_highlight) do
        vim.api.nvim_set_hl(0, group, colors)
    end
end

navic.setup({
    separator = '  ',
    depth_limit = 6,
    highlight = true,
})
