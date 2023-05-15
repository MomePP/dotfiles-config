local M = {
    'echasnovski/mini.bufremove',
}

M.config = function()
    require('mini.bufremove').setup { silent = true }
end

M.keys = function()
    local bufremove_keymap = require('config.keymaps').bufremove

    return {
        { bufremove_keymap.delete, require('mini.bufremove').delete },
    }
end

return M
