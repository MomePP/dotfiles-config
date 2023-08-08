local M = {
    'echasnovski/mini.bufremove',
    main = 'mini.bufremove',
}

M.opts = {
    silent = true,
}

M.keys = function()
    local bufremove_keymap = require('config.keymaps').bufremove

    return {
        { bufremove_keymap.delete, function() require('mini.bufremove').delete() end },
    }
end

return M
