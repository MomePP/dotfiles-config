local M = {
    'AckslD/muren.nvim',
}

M.opts = {
    keys = {
        scroll_preview_up = '<C-u>',
        scroll_preview_down = '<C-d>',
    },
}

M.keys = function()
    local muren_keymap = require('config.keymaps').muren

    return {
        { muren_keymap.toggle, '<Cmd>MurenToggle<CR>' },
        { muren_keymap.unique, '<Cmd>MurenUnique<CR>' },

        { muren_keymap.toggle, "<Esc><Cmd>'<,'>MurenToggle<CR>", mode = 'v' },
        { muren_keymap.unique, "<Esc><Cmd>'<,'>MurenUnique<CR>", mode = 'v' },
    }
end

return M
