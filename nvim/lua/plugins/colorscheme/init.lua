return {
    'momepp/oxocarbon.nvim',
    name = 'nvim-colorscheme',
    -- dev = true,
    lazy = false,
    priority = 1000,
    config = function()
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'oxocarbon'
    end,
}
