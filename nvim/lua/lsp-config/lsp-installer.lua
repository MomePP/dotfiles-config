local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then return end

local lsp_setting_file_path = 'lsp-config.settings.'

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
    local opts = {
        on_attach = require("lsp-config.lsp-handler").on_attach,
        capabilities = require("lsp-config.lsp-handler").capabilities,
    }

    local user_config_exist, user_opts = pcall(require, (lsp_setting_file_path .. server.name))
    if user_config_exist then
        -- print("found user lsp setting: " .. server.name)
        opts = vim.tbl_deep_extend("force", user_opts, opts)
    end

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(opts)
end)

