local M = {
    'echasnovski/mini.bufremove',
}

M.keys = function()
    local bufremove_keymap = require('config.keymaps').bufremove

    return {
        { bufremove_keymap.delete, function() require('mini.bufremove').delete(0, false) end },
        -- { bufremove_keymap.force_delete, function() require('mini.bufremove').delete(0, true) end }
    }
end

return M
