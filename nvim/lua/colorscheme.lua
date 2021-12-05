local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)
utils.opt('o', 'wildoptions', 'pum')
utils.opt('o', 'pumblend', 5)

cmd 'colorscheme plastic'
vim.g.lightline = { colorscheme = 'plastic' }

