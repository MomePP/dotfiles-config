local null_ls_status, null_ls = pcall(require, 'null-ls')
if not null_ls_status then return end

null_ls.setup {}

local mason_null_ls_status, mason_null_ls = pcall(require, 'mason-null-ls')
if not mason_null_ls_status then return end

mason_null_ls.setup {}
mason_null_ls.setup_handlers {
    function(source_name, methods)
        -- all sources with no handler get passed here
        -- Keep original functionality of `automatic_setup = true`
        require('mason-null-ls.automatic_setup')(source_name, methods)
    end,
}
