local M = {
    name = 'nvim-colorscheme',
    -- dev = true,
    lazy = false,
    priority = 1000,
}

-- INFO: selection colorscheme
local theme = require('plugins.colorscheme.oxocarbon-config')
M = vim.tbl_extend('force', M, theme.info)
M.config = theme.setup

return M
