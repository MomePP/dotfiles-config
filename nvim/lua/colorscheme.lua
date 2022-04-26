local cmd = vim.cmd

-- vim.g.plastic_nvim_transparent_bg = true
-- cmd 'colorscheme plastic-nvim'

local kanagawa_colors = require('kanagawa.colors').setup()
local overrided_hlgroup = {
    VertSplit = { fg = kanagawa_colors.sumiInk2, bg = 'NONE' },
    StatusLineNC = { bg = 'NONE' },
}

require('kanagawa').setup({
    undercurl = true,           -- enable undercurls
    transparent = true,        -- do not set background color
    overrides = overrided_hlgroup,
})
cmd 'colorscheme kanagawa'

-- override signcolumn fg to be transparent
cmd 'hi SignColumn guifg=NONE guibg=NONE'
cmd 'hi Pmenu guifg=NONE guibg=NONE'

