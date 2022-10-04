local status_ok, focus = pcall(require, 'focus')
if not status_ok then return end

local focus_configs = {
    excluded_filetypes = {
        'toggleterm',
    },
    excluded_buftypes = {
        'nofile',
        'prompt',
        'popup',
        'terminal'
    },
    excluded_windows = {},
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
