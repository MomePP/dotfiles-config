local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)

-- vim.g.plastic_nvim_transparent_bg = true
-- cmd 'colorscheme plastic-nvim'

require('kanagawa').setup({
    undercurl = true,           -- enable undercurls
    commentStyle = "italic",
    functionStyle = "NONE",
    keywordStyle = "italic",
    statementStyle = "bold",
    typeStyle = "NONE",
    variablebuiltinStyle = "italic",
    specialReturn = true,       -- special highlight for the return keyword
    specialException = true,    -- special highlight for exception handling keywords
    transparent = true,        -- do not set background color
    colors = {},
    overrides = {},
})
cmd 'colorscheme kanagawa'

-- override signcolumn fg to be transparent
cmd 'hi SignColumn guifg=NONE guibg=NONE'
