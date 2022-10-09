local noice_status, noice = pcall(require, 'noice')
if not noice_status then return end

noice.setup {
    cmdline = {
        view = 'cmdline',
        icons = {
            ['?'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            ['/'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            [':'] = { icon = ' ﲵ', hl_group = 'DiagnosticInfo', firstc = false },
        },
    },
    popupmenu = {
        enabled = false
    },
    notify = {
        enabled = false
    }
}

local notify_status, notify = pcall(require, 'notify')
if not notify_status then return end

notify.setup {
    on_open = function(win)
        vim.api.nvim_win_set_config(win, { focusable = false })
    end,
}
