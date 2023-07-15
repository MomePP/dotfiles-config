local M = {
    'echasnovski/mini.move',
    main = 'mini.move',
    config = true,
}

M.keys = function()
    local move_keymap = require('config.keymaps').move

    return {
        { move_keymap.move_up,    mode = { 'n', 'x' } },
        { move_keymap.move_down,  mode = { 'n', 'x' } },
        { move_keymap.move_left,  mode = { 'n', 'x' } },
        { move_keymap.move_right, mode = { 'n', 'x' } },
    }
end

return M
