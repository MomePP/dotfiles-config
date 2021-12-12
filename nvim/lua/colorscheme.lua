local utils = require('utils')
local cmd = vim.cmd

utils.opt('o', 'termguicolors', true)

vim.g.plastic_nvim_transparent_bg = true
cmd 'colorscheme plastic-nvim'

