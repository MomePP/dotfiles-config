local M = {
    'jose-elias-alvarez/null-ls.nvim',
    event = 'BufReadPre',

    dependencies = {
        'jayp0521/mason-null-ls.nvim',
    }
}

M.config = function()
    local null_ls = require('null-ls')
    null_ls.setup {
        border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
    }

    local mason_null_ls = require('mason-null-ls')
    mason_null_ls.setup {}
    mason_null_ls.setup_handlers {
        function(source_name, methods)
            -- all sources with no handler get passed here
            -- Keep original functionality of `automatic_setup = true`
            require('mason-null-ls.automatic_setup')(source_name, methods)
        end,
    }
end

return M
