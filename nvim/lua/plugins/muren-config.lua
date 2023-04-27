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
    }
end

return M
