local status_ok, lsp_setup = pcall(require, 'nvim-lsp-setup')
if not status_ok then return end

local lsp_handler = require('lsp-config.lsp-handler')

lsp_handler.setup()

lsp_setup.setup {
    default_mappings = false,
    mappings = require('keymappings').lsp,
    on_attach = lsp_handler.on_attach,
    capabilities = lsp_handler.capabilities,

    -- Configuration of LSP servers 
    servers = {
        pyright = require('lsp-config.settings.pyright'),
        ccls = require('lsp-config.settings.ccls'),
        vuels = require('lsp-config.settings.vuels'),
        tsserver = require('lsp-config.settings.tsserver'),
        ltex = {},
        jsonls = require('lsp-config.settings.jsonls'),
        sumneko_lua = require('lsp-config.settings.sumneko_lua'),
        cssls = {},
        rust_analyzer = {},
    },
}

