local focus_keymaps = require('config.keymaps').focus

local M = {
    'beauwilliams/focus.nvim',

    keys = {
        { focus_keymaps.toggle_enable, function() require 'focus'.focus_toggle() end, focus_keymaps.opts },
        { focus_keymaps.toggle_size, function() require 'focus'.focus_max_or_equal() end, focus_keymaps.opts },
        { focus_keymaps.split_cycle, function() require 'focus'.split_cycle() end, focus_keymaps.opts },
        { focus_keymaps.split_left, function() require 'focus'.split_command('h') end, focus_keymaps.opts },
        { focus_keymaps.split_right, function() require 'focus'.split_command('l') end, focus_keymaps.opts },
        { focus_keymaps.split_up, function() require 'focus'.split_command('k') end, focus_keymaps.opts },
        { focus_keymaps.split_down, function() require 'focus'.split_command('j') end, focus_keymaps.opts },
    }
}

M.config = function()
    local focus_configs = {
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
    require('focus').setup(focus_configs)
end

return M
