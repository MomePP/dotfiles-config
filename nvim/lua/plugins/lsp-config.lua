local M = {
    'junnplus/lsp-setup.nvim',
    event = 'BufReadPre',

    dependencies = {
        'neovim/nvim-lspconfig',
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
    }
}

M.config = function()
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
        update_in_insert = false,
        virtual_text = false,
        severity_sort = true,
        float = {
            focusable = false,
            style = 'minimal',
            border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
            source = 'always',
            header = '',
            prefix = '',
        },
    }

    -- setup diagnostic signs
    for _, sign in ipairs(diagnostic_signs) do
        vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text })
    end

    -- setup diagnostic configs
    vim.diagnostic.config(diagnostic_config)

    -- ----------------------------------------------------------------------
    --  lsp configs
    --
    local lsp_setup = require('lsp-setup')

    local function lsp_keymaps(bufnr, mapping)
        local opts = { buffer = bufnr, silent = true, noremap = true }
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
        lsp_keymaps(bufnr, require('keymaps').lsp)
        lsp_navic(client, bufnr)
    end

    lsp_setup.setup({
        default_mappings = false,
        on_attach = lsp_on_attach,
        servers = {
            pyright = require('plugins.lsp-settings.pyright'),
            sumneko_lua = require('plugins.lsp-settings.sumneko_lua'),
            volar = require('plugins.lsp-settings.volar'),
            ltex = {},
            cssls = {},
            rust_analyzer = {},
            html = {},
            -- clangd = {},
        }
    })

    -- configure mason after lsp-setup intialized
    require('mason').setup({
        ui = {
            border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
        }
    })

    -- config `lspinfo` window border
    require('lspconfig.ui.windows').default_options.border = {
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
        { ' ', 'NormalFloat' },
    }

    -- manually injects unsupported lsp by mason.nvim
    require('lspconfig')['ccls'].setup({
        on_attach = lsp_on_attach,
        settings = {
            ['ccls'] = require('plugins.lsp-settings.ccls')
        }
    })
end

return M
