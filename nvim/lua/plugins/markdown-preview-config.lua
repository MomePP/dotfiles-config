local markdown_preview_keymap = require('config.keymaps').markdown_preview

local M = {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
}

M.config = function()
    vim.g.mkdp_filetypes = { 'markdown' }
    vim.keymap.set('n', markdown_preview_keymap.toggle, '<Cmd>MarkdownPreviewToggle<CR>', markdown_preview_keymap.opts)
end

return M
