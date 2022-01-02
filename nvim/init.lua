-- nvim setting configs
require('settings')
require('impatient')
-- require('impatient').enable_profile()

-- apply colorscheme
require('colorscheme')

-- install plugins
require('packer_compiled')
require('plugins')

-- key mappings
require('keymappings')

-- setup lsp server
require('lsp-config')

-- plugin configs
require('plugins-config')

