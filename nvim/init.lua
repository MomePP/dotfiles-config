local fn = vim.fn
local execute = vim.api.nvim_command

-- nvim setting configs
require('settings')

-- install plugins
require('plugins')

-- apply colorscheme
require('colorscheme')

-- key mappings
require('keymappings')

-- setup lsp server
require('lsp_config')

-- plugin configs
require('config')
