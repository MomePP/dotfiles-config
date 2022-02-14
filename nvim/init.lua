-- nvim setting configs
pcall(require, 'settings')
local impatient_status, impatient = pcall(require, 'impatient')
-- if impatient_status then impatient.enable_profile() end

-- install plugins
pcall(require, 'plugins')

-- apply colorscheme
pcall(require, 'colorscheme')

-- key mappings
pcall(require, 'keymappings')

-- setup lsp server
pcall(require, 'lsp-config')

-- plugin configs
pcall(require, 'plugins-config')

