return {
    {
        -- ----------------------------------------------------------------------
        -- INFO: lsp server manager config
        --
        'williamboman/mason.nvim',
        cmd = 'Mason',

        config = function()
            require('mason').setup {
                ui = {
                    border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
                }
            }
        end
    },
    {
        -- ----------------------------------------------------------------------
        -- INFO: LSP config
        --
        'junnplus/lsp-setup.nvim',
        event = 'BufReadPre',

        dependencies = {
            'mason.nvim',
            'neovim/nvim-lspconfig',
            'williamboman/mason-lspconfig.nvim',
        },
        config = function()
            -- ----------------------------------------------------------------------
            --  diagnostics configs
            --

            -- setup diagnostic signs
            for name, icon in pairs(require('config').icons.diagnostics) do
                name = 'DiagnosticSign' .. name
                vim.fn.sign_define(name, { texthl = name, text = icon, numhl = '' })
            end

            -- setup diagnostic configs
            local diagnostic_config = {
                update_in_insert = false,
                virtual_text = false,
                severity_sort = true,
            }
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
                lsp_keymaps(bufnr, require('config.keymaps').lsp)
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
    },
    {
        -- ----------------------------------------------------------------------
        -- INFO: formatters config
        --
        'jose-elias-alvarez/null-ls.nvim',
        event = 'BufReadPost',

        dependencies = {
            'mason.nvim',
            'jayp0521/mason-null-ls.nvim',
        },

        config = function()
            local mason_null_ls = require('mason-null-ls')
            mason_null_ls.setup { automatic_setup = true }

            local null_ls = require('null-ls')
            null_ls.setup {
                border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
            }

            mason_null_ls.setup_handlers {}
        end
    }
}
