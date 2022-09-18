local status_ok, focus = pcall(require, 'focus')
if not status_ok then return end

focus.setup({
    excluded_filetypes = {
        'toggleterm',
    },
    excluded_buftypes = {
        'nofile',
        'prompt',
        'popup'
    },
    autoresize = false,
    number = false,
    signcolumn = false,
})


-- INFO: register user autocmd to prevents resized notifier's window
-- INFO:    this need `notifier` to triggers autocmd by remove `noautocmd` option when open new window
vim.api.nvim_create_autocmd('BufEnter', {
    desc = '`focus.nvim` resized windows',
    pattern = '*',
    callback = function()
        local is_notifier_ok, notifier_status_module = pcall(require, 'notifier.status')
        if not is_notifier_ok or notifier_status_module.win_nr ~= nil then return end
        vim.api.nvim_exec_autocmds('WinScrolled', {})
        focus.resize()
    end
})
