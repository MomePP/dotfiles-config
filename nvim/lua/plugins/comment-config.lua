local M = {
    'numToStr/Comment.nvim',
    dependencies = {
        'nvim-ts-context-commentstring',
    },
}

M.opts = function()
    return {
        mappings = { extra = false },
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
    }
end

M.keys = {
    { 'gc', mode = { 'n', 'v', 'o' } },
    { 'gb', mode = { 'n', 'v', 'o' } },
    { 'gcc' },
    { 'gbc' }
}

return M
