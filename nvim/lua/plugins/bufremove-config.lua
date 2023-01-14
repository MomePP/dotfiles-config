local bufremove_keymap = require('config.keymaps').bufremove

local M = {
    'echasnovski/mini.bufremove',
}

M.keys = {
    { bufremove_keymap.delete, function() require('mini.bufremove').delete(0, false) end, bufremove_keymap.opts },
    -- { bufremove_keymap.force_delete, function() require('mini.bufremove').delete(0, true) end, bufremove_keymap.opts }
}

return M
