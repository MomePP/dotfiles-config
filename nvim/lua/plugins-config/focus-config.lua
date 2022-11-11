local status_ok, focus = pcall(require, 'focus')
if not status_ok then return end

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


-- INFO: changed user autocmd to prevents resized notifier's window
-- INFO:    this need `notifier` to triggers autocmd by remove `noautocmd` option when open new window
-- local notifier_ok, notifier_status_module = pcall(require, 'notifier.status')
-- vim.api.nvim_create_autocmd('BufEnter', {
--     desc = '`focus.nvim` resized windows',
--     pattern = '*',
--     callback = function()
--         if notifier_ok and notifier_status_module.win_nr ~= nil then
--             table.insert(focus_configs.excluded_windows, notifier_status_module.win_nr)
--             focus.setup(focus_configs)
--         end
--         vim.api.nvim_exec_autocmds('WinScrolled', {})
--         focus.resize()
--     end
-- })

local focus_keymaps = require('keymappings').focus

vim.keymap.set('n', focus_keymaps.toggle_enable, focus.focus_toggle, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.toggle_size, focus.focus_max_or_equal, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.split_cycle, focus.split_cycle, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.split_left, function() focus.split_command('h') end, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.split_right, function() focus.split_command('l') end, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.split_up, function() focus.split_command('k') end, focus_keymaps.opts)
vim.keymap.set('n', focus_keymaps.split_down, function() focus.split_command('j') end, focus_keymaps.opts)
