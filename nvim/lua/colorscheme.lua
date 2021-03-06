-- vim.g.plastic_nvim_transparent_bg = true
-- vim.cmd('colorscheme plastic-nvim')

require('kanagawa').setup({
    transparent = true, -- do not set background color
    globalStatus = true,
    terminalColors = false,
})
vim.cmd('colorscheme kanagawa')

-- override signcolumn fg to be transparent
vim.api.nvim_set_hl(0, 'SignColumn', { fg = 'NONE', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = 'NONE', bg = 'NONE' })
