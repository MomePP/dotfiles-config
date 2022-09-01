-- vim.g.plastic_nvim_transparent_bg = true
-- vim.cmd('colorscheme plastic-nvim')

vim.cmd('set background=light')

-- INFO: kanagawa theme config
require('kanagawa').setup({
    transparent = true, -- do not set background color
    globalStatus = true,
    terminalColors = false,
})
vim.cmd.colorscheme 'kanagawa'

-- INFO: adwaita theme config
-- vim.g.adwaita_darker = true
-- vim.cmd.colorscheme('adwaita')

-- override signcolumn fg to be transparent
vim.api.nvim_set_hl(0, 'SignColumn', { fg = 'NONE', bg = 'NONE' })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = 'NONE', bg = 'NONE' })

-- override floatborder bg
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'NONE' })
