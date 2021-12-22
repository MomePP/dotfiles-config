local fn = vim.fn
local execute = vim.api.nvim_command

-- nvim setting configs
require('settings')

-- install plugins
require('plugins')

-- apply colorscheme
require('colorscheme')

-- setup lsp server
require('lsp-config')

-- plugin configs
require('plugins-config')

-- key mappings
require('keymappings')
