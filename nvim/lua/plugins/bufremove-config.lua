local bufremove_keymap = require('keymaps').bufremove

local M = {
    'echasnovski/mini.bufremove',
    keys = {
        { bufremove_keymap.delete, function() require('mini.bufremove').delete(0, false) end, bufremove_keymap.opts },
        { bufremove_keymap.force_delete, function() require('mini.bufremove').delete(0, true) end, bufremove_keymap.opts }
    }
}

return M
