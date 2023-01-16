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
    local focus = require('focus')
    local focus_keymaps = require('config.keymaps').focus

    return {
        { focus_keymaps.toggle_enable, function() focus.focus_toggle() end },
        { focus_keymaps.toggle_size, function() focus.focus_max_or_equal() end },
        { focus_keymaps.split_cycle, function() focus.split_cycle() end },
        { focus_keymaps.split_left, function() focus.split_command('h') end },
        { focus_keymaps.split_right, function() focus.split_command('l') end },
        { focus_keymaps.split_up, function() focus.split_command('k') end },
        { focus_keymaps.split_down, function() focus.split_command('j') end },
    }
end

return M
