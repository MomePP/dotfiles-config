local M = {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
    event = 'VeryLazy'
}

M.init = function()
    -- INFO: extends action to close and focus back on active split
    local trouble = require('trouble')
    trouble.close_to_parent = function()
        trouble.action('cancel')
        trouble.close()
    end
end

M.opts = {
    use_diagnostic_signs = true,
    action_keys = {
        close = {},
        cancel = {},
        close_to_parent = { 'q', '<esc>' },
        jump = { '<tab>', '<space>' },
        jump_close = { '<cr>', 'o' }
    }
}

return M
