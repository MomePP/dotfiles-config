local move_keymap = require('config.keymaps').move

local M = {
    'echasnovski/mini.move',
    main = 'mini.move',
}

M.opts = {
    mappings = {
        left = move_keymap.move_left,
        right = move_keymap.move_right,
        down = move_keymap.move_down,
        up = move_keymap.move_up,

        line_left = move_keymap.move_left,
        line_right = move_keymap.move_right,
        line_down = move_keymap.move_down,
        line_up = move_keymap.move_up,
    }
}

M.keys = {
    { move_keymap.move_up,    mode = { 'n', 'x' } },
    { move_keymap.move_down,  mode = { 'n', 'x' } },
    { move_keymap.move_left,  mode = { 'n', 'x' } },
    { move_keymap.move_right, mode = { 'n', 'x' } },
}

return M
