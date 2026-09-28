local M = {}

M.info = {
    'momepp/oxocarbon.nvim',
    colorscheme = 'oxocarbon',
}

M.setup = function()
    vim.opt.background = 'dark'
    vim.cmd.colorscheme 'oxocarbon'
end

return M
