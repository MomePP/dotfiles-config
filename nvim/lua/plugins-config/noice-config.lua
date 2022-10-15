local noice_status, noice = pcall(require, 'noice')
if not noice_status then return end

noice.setup {
    views = {
        mini = {
            focusable = false,
            timeout = 3000,
        },
    },
    cmdline = {
        view = 'cmdline',
        icons = {
            ['?'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            ['/'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            [':'] = { icon = ' ', hl_group = 'DiagnosticError', firstc = false },
        },
    },
    notify = {
        enable = false,
    },
    lsp_progress = {
        enable = true,
    },
    routes = {
        {
            filter = {
                any = {
                    { event = { 'msg_showmode', 'msg_showcmd', 'msg_ruler' } },
                    { event = 'msg_show', kind = 'search_count' },
                },
            },
            opts = { skip = true },
        },
        {
            view = 'mini',
            filter = {
                any = {
                    { event = 'msg_show', kind = { 'echo', '' } },
                    { event = 'notify' },
                    { event = 'noice' },
                    { error = true },
                    { warning = true },
                },
            },
        },
    },
}

-- INFO: disable notify can be focusable when popping
local notify_status, notify = pcall(require, 'notify')
if notify_status then
    notify.setup {
        on_open = function(win)
            vim.api.nvim_win_set_config(win, { focusable = false })
        end,
    }
end
