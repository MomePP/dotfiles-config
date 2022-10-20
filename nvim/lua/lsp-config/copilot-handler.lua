-- ----------------------------------------------------------------------
--  github co-pilot configs
--
local copilot_loaded, copilot = pcall(require, 'copilot')
if copilot_loaded then

    -- check lsp encoding before setup
    local offset_encoding = 'utf-16'
    local active_clients = vim.lsp.get_active_clients({ name = 'ccls' })[1]
    if active_clients then
        offset_encoding = 'utf-32'
    end

    copilot.setup {
        server_opts_overrides = {
            offset_encoding = offset_encoding,
        }
    }

    -- trying to load cmp for co-pilot
    local copilot_cmp_loaded, copilot_cmp = pcall(require, 'copilot_cmp')
    if copilot_cmp_loaded then
        copilot_cmp.setup {}
    end
end
