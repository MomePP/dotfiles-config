local M = {
    'AckslD/muren.nvim',
    config = true,
}

M.keys = function()
    local muren_keymap = require('config.keymaps').muren

    return {
        { muren_keymap.toggle, '<Cmd>MurenToggle<CR>' },
        { muren_keymap.unique, '<Cmd>MurenUnique<CR>' },
    }
end

return M
