local M = {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    build = function() vim.fn['mkdp#util#install']() end,
}

M.init = function()
    vim.g.mkdp_filetypes = { 'markdown' }
end

return M
