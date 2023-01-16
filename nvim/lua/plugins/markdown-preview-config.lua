local M = {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
}

M.init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
end

M.keys = function()
    local markdown_preview_keymap = require('config.keymaps').markdown_preview

    return {
        { markdown_preview_keymap.toggle, '<Cmd>MarkdownPreviewToggle<CR>' }
    }
end

return M
