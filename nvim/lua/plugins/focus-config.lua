local M = {
    'beauwilliams/focus.nvim',
}

M.opts = {
    excluded_filetypes = {
        '',
        'TelescopePrompt',
        'toggleterm',
        'noice',
    },
    excluded_buftypes = {
        'nofile',
        'prompt',
        'popup',
        'terminal'
    },
    autoresize = true,
    number = false,
    signcolumn = false,
}

M.keys = function()
    local focus_keymaps = require('config.keymaps').focus

    return {
        { focus_keymaps.toggle_enable, '<Cmd>FocusToggle<CR>' },
        { focus_keymaps.toggle_size, '<Cmd>FocusMaxOrEqual<CR>' },
        { focus_keymaps.split_cycle, '<Cmd>FocusSplitCycle<CR>' },
        { focus_keymaps.split_left, '<Cmd>FocusSplitLeft<CR>' },
        { focus_keymaps.split_right, '<Cmd>FocusSplitRight<CR>' },
        { focus_keymaps.split_up, '<Cmd>FocusSplitUp<CR>' },
        { focus_keymaps.split_down, '<Cmd>FocusSplitDown<CR>' },
    }
end

return M
