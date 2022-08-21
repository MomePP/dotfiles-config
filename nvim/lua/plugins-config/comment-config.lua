local status_ok, comment = pcall(require, 'Comment')
if not status_ok then return end

comment.setup {
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
}

-- fallback comment string if not found by plugin
vim.bo.commentstring = '//%s'

local ft = require('Comment.ft')

-- Multiple filetypes
ft({ 'json', 'rust' }, { '//%s', '/*%s*/' })
ft({ 'toml', 'graphql' }, '#%s')
