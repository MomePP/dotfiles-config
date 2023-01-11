local M = {
    'beauwilliams/focus.nvim',
    event = 'BufReadPre'
}

M.config = function()
    local focus = require('focus')
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
    focus.setup(focus_configs)

    local focus_keymaps = require('config.keymaps').focus
    vim.keymap.set('n', focus_keymaps.toggle_enable, focus.focus_toggle, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.toggle_size, focus.focus_max_or_equal, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.split_cycle, focus.split_cycle, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.split_left, function() focus.split_command('h') end, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.split_right, function() focus.split_command('l') end, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.split_up, function() focus.split_command('k') end, focus_keymaps.opts)
    vim.keymap.set('n', focus_keymaps.split_down, function() focus.split_command('j') end, focus_keymaps.opts)
end

return M
