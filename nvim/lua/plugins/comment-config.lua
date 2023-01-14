local M = {
    'numToStr/Comment.nvim',
    event = 'BufReadPost',
    dependencies = {
        'nvim-ts-context-commentstring'
    },
}

function M.config()
    require('Comment').setup {
        mappings = { extra = false },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
    }
end

return M
