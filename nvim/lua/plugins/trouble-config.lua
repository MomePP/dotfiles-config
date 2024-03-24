local M = {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
}

M.opts = {
    use_diagnostic_signs = true,
    action_keys = {
        cancel = {},
        close = { 'q', '<esc>' },
        jump = { '<tab>', '<space>' },
        jump_close = { '<cr>', 'o' }
    }
}

return M
