local M = {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        {
            'echasnovski/mini.indentscope',
            init = function()
                local ignore_buftypes = { 'terminal' }
                local augroup = vim.api.nvim_create_augroup('IndentscopeDisable', { clear = true })

                vim.api.nvim_create_autocmd('BufEnter', {
                    group = augroup,
                    callback = function(_)
                        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
                        then
                            vim.b.miniindentscope_disable = true
                        else
                            vim.b.miniindentscope_disable = false
                        end
                    end,
                    desc = 'Disable mini.indentscope for buftype',
                })
            end,
            opts = {
                symbol = '•',
            },
        }
    }
}

M.opts = {
    indent = {
        char = '•',
        smart_indent_cap = true,
    },
    scope = {
        enabled = false,
    }
}

M.config = function(_, opts)
    require('ibl').setup(opts)

    local hooks = require('ibl.hooks')
    hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)
end

return M
