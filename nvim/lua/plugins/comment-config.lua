local M = {
    'numToStr/Comment.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
    },
}

M.opts = function()
    return {
        mappings = { extra = false },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
    }
end

return M
