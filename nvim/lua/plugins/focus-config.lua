local M = {
    'beauwilliams/focus.nvim',
    event = 'VeryLazy'
}

M.opts = {
    excluded_filetypes = {
        'telescopeprompt',
        'toggleterm',
        'noice',
    },
    autoresize = true,
    number = false,
    signcolumn = false,
    cursorline = true,
}

M.keys = function()
    local focus_keymaps = require('config.keymaps').focus

    return {
        { focus_keymaps.toggle_enable, '<Cmd>FocusToggle<CR>' },
        { focus_keymaps.toggle_size,   '<Cmd>FocusMaxOrEqual<CR>' },
        { focus_keymaps.split_cycle,   '<Cmd>FocusSplitCycle<CR>' },
        { focus_keymaps.split_left,    '<Cmd>FocusSplitLeft<CR>' },
        { focus_keymaps.split_right,   '<Cmd>FocusSplitRight<CR>' },
        { focus_keymaps.split_up,      '<Cmd>FocusSplitUp<CR>' },
        { focus_keymaps.split_down,    '<Cmd>FocusSplitDown<CR>' },
    }
end

return M
