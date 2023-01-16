local M = {
    'booperlv/nvim-gomove',
    event = 'BufReadPost'
}

M.opts = {
    map_defaults = true
}

M.keys = function()
    local gomove_keymap = require('config.keymaps').gomove

    return {
        -- INFO: add extra mapping for insert mode
        { gomove_keymap.move_up, '<Esc><Plug>GoNSMUpgi', mode = 'i' },
        { gomove_keymap.move_down, '<Esc><Plug>GoNSMDowngi', mode = 'i' },
        { gomove_keymap.dup_up, '<Esc><Plug>GoNSDUpgi', mode = 'i' },
        { gomove_keymap.dup_down, '<Esc><Plug>GoNSDDowngi', mode = 'i' },
    }
end

return M
