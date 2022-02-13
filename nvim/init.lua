-- nvim setting configs
require('settings')
local impatient_status, impatient = pcall(require, 'impatient')
-- if impatient_status then impatient.enable_profile() end

-- install plugins
require('plugins')
require('packer_compiled')

-- apply colorscheme
require('colorscheme')

-- key mappings
require('keymappings')

-- setup lsp server
require('lsp-config')

-- plugin configs
require('plugins-config')

