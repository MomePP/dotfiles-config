local M = {
    'lucastavaresa/SingleComment.nvim',
    dependencies = {
        { 'nvim-treesitter' },
        {
            'JoosepAlviste/nvim-ts-context-commentstring',
            opts = { enable_autocmd = false },
        },
    }
}

M.keys = {
    { mode = { 'n' },      'gcc', function() return require('SingleComment').SingleComment() end, expr = true },
    { mode = { 'v' },      'gcc', function() require('SingleComment').Comment() end },
    { mode = { 'n' },      'gca', function() require('SingleComment').ToggleCommentAhead() end },
    { mode = { 'n' },      'gcA', function() require('SingleComment').CommentAhead() end },
    { mode = { 'n', 'v' }, 'gcb', function() require('SingleComment').BlockComment() end },
}

return M
