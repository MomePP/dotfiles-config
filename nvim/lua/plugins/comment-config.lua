local M = {
    'echasnovski/mini.comment',
    keys = {
        { 'gcc' },
        { 'gc', mode = { 'n', 'v' } },
    },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring'
    },
}

function M.config()
    local comment = require('mini.comment')
    comment.setup {
        hooks = {
            pre = function()
                require('ts_context_commentstring.internal').update_commentstring({})
            end
        }
    }
end

return M
