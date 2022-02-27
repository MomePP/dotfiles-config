local status_ok, lsp_installer_servers = pcall(require, "nvim-lsp-installer.servers")
if not status_ok then return end

local servers = {
    "pyright",
    "ccls",
    "vuels",
    "tsserver",
    "ltex",
    "jsonls",
    "sumneko_lua",
    "cssls",
    "rust_analyzer"
}
local lsp_setting_file_path = 'lsp-config.settings.'

-- Loop through the servers listed above and set them up. If a server is
-- not already installed, install it.
for _, server_name in pairs(servers) do
    local server_available, server = lsp_installer_servers.get_server(server_name)
    if server_available then
        server:on_ready(function ()
            -- When this particular server is ready (i.e. when installation is finished or the server is already installed),
            -- this function will be invoked. Make sure not to also use the "catch-all" lsp_installer.on_server_ready()
            -- function to set up your servers, because by doing so you'd be setting up the same server twice.
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
        if not server:is_installed() then
            -- Queue the server to be installed.
            server:install()
        end
    end
end

