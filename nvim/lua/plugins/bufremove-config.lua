local M = {
    'echasnovski/mini.bufremove',
}

M.keys = function()
    local bufremove = require('mini.bufremove')
    local bufremove_keymap = require('config.keymaps').bufremove

    return {
        { bufremove_keymap.delete, function() bufremove.delete(0, false) end },
        -- { bufremove_keymap.force_delete, function() bufremove.delete(0, true) end }
    }
end

return M
