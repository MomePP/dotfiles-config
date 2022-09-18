-- ----------------------------------------------------------------------
--  diagnostics configs
--
local diagnostic_signs = {
    { name = 'DiagnosticSignError', text = '' },
    { name = 'DiagnosticSignWarn', text = '▲' },
    { name = 'DiagnosticSignHint', text = '' },
    { name = 'DiagnosticSignInfo', text = '' },
}

local diagnostic_config = {
    virtual_text = false,
    severity_sort = true,
    float = {
        focusable = false,
        style = 'minimal',
        border = 'rounded',
        source = 'always',
        header = '',
        prefix = '',
    },
}

local handler_config = {
    border = 'rounded',
    focusable = false,
    noautocmd = true
}

-- setup diagnostic signs
for _, sign in ipairs(diagnostic_signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text })
end

-- setup diagnostic configs
vim.diagnostic.config(diagnostic_config)

-- setup round bordered floating window for cursor hover and signature help
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with( vim.lsp.handlers.hover, handler_config)
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, handler_config)

-- ----------------------------------------------------------------------
--  lsp configs
--
local lsp_status_ok, lsp_setup = pcall(require, 'lsp-setup')
if not lsp_status_ok then return end

local function lsp_keymaps(bufnr, mapping)
    local opts = { buffer = bufnr, silent = true, remap = false }
    for key, cmd in pairs(mapping or {}) do
        vim.keymap.set('n', key, cmd, opts)
    end
end

local function lsp_navic(client, bufnr)
    local loaded_plugin, navic = pcall(require, 'nvim-navic')
    if not loaded_plugin then return end

    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end
end

local function lsp_on_attach(client, bufnr)
    lsp_keymaps(bufnr, require('keymappings').lsp)
    lsp_navic(client, bufnr)
end

lsp_setup.setup({
    default_mappings = false,
    on_attach = lsp_on_attach,
    servers = {
        pyright = require('lsp-config.settings.pyright'),
        tsserver = require('lsp-config.settings.tsserver'),
        jsonls = require('lsp-config.settings.jsonls'),
        sumneko_lua = require('lsp-config.settings.sumneko_lua'),
        ltex = {},
        cssls = {},
        rust_analyzer = {},
        volar = {},
        html = {},
        -- clangd = {},
    }
})

-- configure mason after lsp-setup intialized
require('mason').setup({
    ui = {
        border = 'rounded'
    }
})

-- manually injects unsupported lsp by mason.nvim
require('lspconfig')['ccls'].setup({
    on_attach = lsp_on_attach,
    settings = {
        ['ccls'] = require('lsp-config.settings.ccls')
    }
})
