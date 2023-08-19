local M = {
    'stevearc/dressing.nvim',
    event = 'VeryLazy',
    enabled = false,
}

M.opts = function()
    local default_border = require('config').defaults.float_border

    return {
        input = {
            border = default_border,
            win_options = {
                winblend = 0,
                winhighlight = 'NormalFloat:NormalFloat'
            }
        },
        select = {
            backend = 'builtin',
            builtin = {
                border = default_border,
                win_options = { winblend = 0 }
            },
            get_config = function(opts)
                if opts.kind == 'codeaction' then
                    return { builtin = { relative = 'cursor' } }
                end
            end
        },
    }
end

return M
