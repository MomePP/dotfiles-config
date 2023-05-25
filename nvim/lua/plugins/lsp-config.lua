local default_config = require('config').defaults

-- ----------------------------------------------------------------------
-- INFO: lsp server manager config
--
local mason_module = {
    'williamboman/mason.nvim',
    cmd = { 'Mason', 'MasonUpdate' },
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
    'VonHeikemen/lsp-zero.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
        'mason.nvim',
        'cmp-nvim-lsp',
        'neovim/nvim-lspconfig',
        'williamboman/mason-lspconfig.nvim',
    },
}

lsp_setup_module.init = function()
    -- INFO: setup diagnostic configs
    local diagnostic_config = {
        update_in_insert = false,
        virtual_text = false,
        severity_sort = true,
        virtual_lines = {
            severity = {
                min = vim.diagnostic.severity.INFO
            }
        }
    }
    vim.diagnostic.config(diagnostic_config)

    -- INFO: overrides globally default of `open_floating_preview`
    local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.focus = opts.focusable or false
        opts.offset_x = opts.offset_x or -2
        opts.offset_y = opts.offset_y or 0

        -- NOTE: padding contents
        for index, message in ipairs(contents) do
            contents[index] = string.format(' %s ', message)
        end
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
    end
end

lsp_setup_module.config = function()
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

    -- INFO: check if eslint is attach then enable documentFormattingProvider
    local function check_eslint(client)
        if client.name == 'eslint' then
            client.server_capabilities.documentFormattingProvider = true
            return true
        end
        return false
    end

    -- INFO: config lsp keymaps
    local function lsp_keymap(client, bufnr, mapping)
        local opts = { buffer = bufnr, silent = true, noremap = true }

        -- INFO: always call formatting with restrict to eslint if found
        if check_eslint(client) then
            mapping.format.cmd = function() vim.lsp.buf.format({ async = true, name = client.name }) end
        end

        for _, keymap in pairs(mapping) do
            vim.keymap.set('n', keymap.key, keymap.cmd, opts)
        end
    end

    local lsp = require('lsp-zero').preset {
        name = 'minimal',
        float_border = require('config').defaults.float_border,
        manage_nvim_cmp = {
            set_sources = 'lsp',
            set_basic_mappings = false,
            set_extra_mappings = false,
            use_luasnip = false,
            set_format = false,
            documentation_window = false,
        }
    }

    lsp.set_sign_icons(require('config').defaults.icons.diagnostics)

    lsp.on_attach(function(client, bufnr)
        lsp_keymap(client, bufnr, require('config.keymaps').lsp)
    end)

    -- INFO: config lsp servers in lsp-list
    for name, config in pairs(require('plugins.lsp-settings.lsp-list')) do
        lsp.configure(name, config)
    end

    -- NOTE: manually injects unsupported lsp by mason.nvim
    -- lsp.configure('ccls', {
    --     on_attach = lsp_on_attach,
    -- })

    lsp.setup()
end

-- ----------------------------------------------------------------------
-- INFO: formatters config
--
local null_ls_module = {
    'jay-babu/mason-null-ls.nvim',
    dependencies = {
        'jose-elias-alvarez/null-ls.nvim',
        'mason.nvim',
    },
    event = { 'BufReadPre', 'BufNewFile' },
}

null_ls_module.init = function()
    vim.api.nvim_create_user_command('NullLsToggle', function()
        require('null-ls').toggle({})
    end, {})
end

null_ls_module.config = function()
    require('mason-null-ls').setup {
        ensure_installed = require('plugins.null-ls-settings.null-ls-list'),
        handlers = {}
    }
    require('null-ls').setup {
        border = default_config.float_border,
    }
end

local lsp_lines_module = {
    'MomePP/lsp_lines.nvim',
    dependencies = 'nvim-lspconfig',
    event = 'VeryLazy',
    keys = {
        { require('config.keymaps').lsp_lines.toggle, '<Cmd>LspLinesToggleSeverity<CR>' }
    }
}

lsp_lines_module.config = function()
    -- INFO: store user severity config as a limit, if exist
    local user_severity_limit = (vim.diagnostic.config().virtual_lines.severity.min or vim.diagnostic.severity.HINT)
    local current_severity = user_severity_limit

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
            current_severity = (current_severity + 1) % (user_severity_limit + 1)
            setSeverityConfig(current_severity)
            vim.notify(string.format('[virtual lines] diagnostic level: %d', current_severity), vim.log.levels.INFO)
        end,
        { nargs = 0 }
    )

    require('lsp_lines').setup()
end

return {
    mason_module,
    lsp_setup_module,
    null_ls_module,
    lsp_lines_module,
}
