local M = {
    'folke/trouble.nvim',
    cmd = 'TroubleToggle',
}

M.opts = function()
    -- INFO: extends action to close and focus back on active split
    local trouble = require('trouble')
    trouble.close_to_parent = function()
        trouble.action('cancel')
        trouble.close()
    end

    return {
        use_diagnostic_signs = true,
        action_keys = {
            close = {},
            cancel = {},
            close_to_parent = { 'q', '<esc>' },
            jump = { '<tab>', '<space>' },
            jump_close = { '<cr>', 'o' }
        }
    }
end

return M
