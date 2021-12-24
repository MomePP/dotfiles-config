local status_ok, _ = pcall(require, 'lspconfig')
if not status_ok then return end

require('lsp-config.lsp-installer')
require('lsp-config.lsp-handler').setup()

