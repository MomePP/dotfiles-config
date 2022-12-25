local M = {
    'numToStr/Comment.nvim',
    keys = {
        { 'gcc' },
        { 'gc', mode = 'v' },
        { 'gbc', mode = { 'n', 'v' } },
    },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring'
    },
}

function M.config()
    local comment = require('Comment')
    comment.setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    }
    -- fallback comment string if not found by plugin
    vim.bo.commentstring = '//%s'

    local ft = require('Comment.ft')
    ft({ 'json', 'rust' }, { '//%s', '/*%s*/' })
    ft({ 'toml', 'graphql' }, '#%s')
end

return M
