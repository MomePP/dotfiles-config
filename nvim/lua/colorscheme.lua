-- vim.g.plastic_nvim_transparent_bg = true
-- vim.cmd('colorscheme plastic-nvim')

local kanagawa_colors = require('kanagawa.colors').setup()
local overrided_hlgroup = {
    VertSplit = { fg = kanagawa_colors.sumiInk2, bg = 'NONE' },
    StatusLineNC = { bg = 'NONE' },
}

require('kanagawa').setup({
    undercurl = true, -- enable undercurls
    transparent = true, -- do not set background color
    overrides = overrided_hlgroup,
})
vim.cmd('colorscheme kanagawa')

-- override signcolumn fg to be transparent
vim.api.nvim_set_hl(0, 'SignColumn', { fg = 'NONE', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = 'NONE', bg = 'NONE' })
