local status_ok, lsp = pcall(require, 'lsp-zero')
if not status_ok then return end

-- ----------------------------------------------------------------------
--  lsp configs
--
local lsp_keys_mapping = require('keymappings').lsp

local function lsp_highlight_document(client)
    local loaded_plugin, illuminate = pcall(require, 'illuminate')
    if not loaded_plugin then return end

    illuminate.on_attach(client)
end

local function lsp_keymaps(bufnr, mapping)
    local opts = { buffer = bufnr, silent = true, remap = false }
    for key, cmd in pairs(mapping or {}) do
        vim.keymap.set('n', key, cmd, opts)
    end
end

lsp.set_preferences({
    suggest_lsp_servers = true,
    setup_servers_on_start = true,
    set_lsp_keymaps = false,
    configure_diagnostics = true,
    cmp_capabilities = true,
    manage_nvim_cmp = false,
    call_servers = 'local',
    sign_icons = {
        error = '',
        warn = '▲',
        hint = '',
        info = ''
    }
})

lsp.on_attach(function(client, bufnr)
    lsp_keymaps(bufnr, lsp_keys_mapping)
    lsp_highlight_document(client)
end)

-- config lsp per language
lsp.configure('tsserver', {
    on_attach = function(client, bufnr)
        client.resolved_capabilities.document_formatting = false
    end
})
lsp.use('pyright', require('lsp-config.settings.pyright'), true)
lsp.use('sumneko_lua', require('lsp-config.settings.sumneko_lua'), true)
lsp.use('tsserver', require('lsp-config.settings.tsserver'), true)
lsp.use('ccls', require('lsp-config.settings.ccls'), true)
lsp.use('vuels', require('lsp-config.settings.vuels'), true)
lsp.use('jsonls', require('lsp-config.settings.jsonls'), true)

-- start the LSP plugin ...
lsp.setup()
