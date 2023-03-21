local default_config = require('config').defaults

-- ----------------------------------------------------------------------
-- INFO: lsp server manager config
--
local mason_module = {
    'williamboman/mason.nvim',
    cmd = 'Mason',
}

mason_module.opts = {
    ui = {
        border = default_config.float_border
    }
}

-- ----------------------------------------------------------------------
-- INFO: LSP config
--
local lsp_setup_module = {
    'junnplus/lsp-setup.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'mason.nvim',
        'cmp-nvim-lsp',
        'neovim/nvim-lspconfig',
        'williamboman/mason-lspconfig.nvim',
    },
}

lsp_setup_module.config = function()
    -- ----------------------------------------------------------------------
    --  diagnostics configs
    --

    -- setup diagnostic signs
    for name, icon in pairs(default_config.icons.diagnostics) do
        name = 'DiagnosticSign' .. name
        vim.fn.sign_define(name, { texthl = name, text = icon, numhl = '' })
    end

    -- setup diagnostic configs
    local diagnostic_config = {
        update_in_insert = false,
        virtual_text = false,
        severity_sort = true,
        virtual_lines = {
            severity = {
                min = vim.diagnostic.severity.HINT
            }
        }
    }
    vim.diagnostic.config(diagnostic_config)

    -- ----------------------------------------------------------------------
    --  lsp configs
    --
    local lspconfig = require('lspconfig')

    local load_local_settings = function(path, server_name)
        vim.validate { path = { path, 's' } }

        local fname = string.format("%s/%s.json", path, server_name)
        local ok, result = pcall(vim.fn.readfile, fname)
        if not ok then return nil end

        result = table.concat(result)
        result = vim.json.decode(result)
        return result
    end

    -- INFO:  inject `esp-clang`, use specific fork clang from espressif
    --  also add `query-driver` for specific toolchains not from builtin binary
    lspconfig.util.default_config = vim.tbl_extend('force', lspconfig.util.default_config, {
        on_new_config = lspconfig.util.add_hook_before(lspconfig.util.default_config.on_new_config,
            function(config, root_dir)
                local new_default_config = load_local_settings(root_dir, config.name)
                if new_default_config ~= nil then
                    config.cmd = new_default_config.cmd
                    -- config = vim.tbl_deep_extend('force', config, new_default_config) -- BUG: not sure why its cannot extended table, shallow copy ?
                end
            end)
    })

    -- INFO: config lsp log with formatting
    vim.lsp.set_log_level 'off' --    Levels by name: "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "OFF"
    -- require('vim.lsp.log').set_format_func(vim.inspect)

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
        servers = require('plugins.lsp-settings.lsp-list')
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

    -- NOTE: manually injects unsupported lsp by mason.nvim
    -- lspconfig.ccls.setup {
    --     on_attach = lsp_on_attach,
    -- }
end

-- ----------------------------------------------------------------------
-- INFO: formatters config
--
local null_ls_module = {
    'jose-elias-alvarez/null-ls.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'mason.nvim',
        'jayp0521/mason-null-ls.nvim',
    },
}

null_ls_module.config = function()
    local mason_null_ls = require('mason-null-ls')
    mason_null_ls.setup { automatic_setup = true }

    local null_ls = require('null-ls')
    null_ls.setup {
        border = default_config.float_border
    }

    mason_null_ls.setup_handlers {}
end

local lsp_lines_module = {
    'MomePP/lsp_lines.nvim',
    dependencies = 'nvim-lspconfig',
    event = { 'BufReadPost', 'BufNewFile' },
    config = true,
    keys = {
        { require('config.keymaps').lsp_lines.toggle, '<Cmd>LspLinesToggleSeverity<CR>' }
    }
}

lsp_lines_module.init = function()
    local current_severity = 1
    local function setSeverityConfig(min_severity)
        local config = {}
        if min_severity == 0 then
            config.virtual_lines = false
        else
            config.virtual_lines = { severity = { min = min_severity } }
        end
        vim.diagnostic.config(config)
    end

    vim.api.nvim_create_user_command('LspLinesToggleSeverity', function()
        current_severity = (current_severity + 1) % 5
        setSeverityConfig(current_severity)
        end,
        { nargs = 0 }
    )
end

return {
    mason_module,
    lsp_setup_module,
    null_ls_module,
    lsp_lines_module,
}
