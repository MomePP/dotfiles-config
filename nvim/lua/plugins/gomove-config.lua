
local M = {
    'booperlv/nvim-gomove',
    event = 'BufReadPost',
}

M.config = function()
    require('gomove').setup {
        map_defaults = true
    }

    -- INFO: add extra mapping for insert mode
    local gomove_keymap = require('config.keymaps').gomove

    -- move line
    vim.keymap.set('i', gomove_keymap.move_up, '<Esc><Plug>GoNSMUpgi', gomove_keymap.opts)
    vim.keymap.set('i', gomove_keymap.move_down, '<Esc><Plug>GoNSMDowngi', gomove_keymap.opts)

    -- duplicate line
    vim.keymap.set('i', gomove_keymap.dup_up, '<Esc><Plug>GoNSDUpgi', gomove_keymap.opts)
    vim.keymap.set('i', gomove_keymap.dup_down, '<Esc><Plug>GoNSDDowngi', gomove_keymap.opts)
end

return M
