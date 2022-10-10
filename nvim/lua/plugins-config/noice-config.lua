local noice_status, noice = pcall(require, 'noice')
if not noice_status then return end

noice.setup {
    cmdline = {
        view = 'cmdline',
        icons = {
            ['?'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            ['/'] = { icon = ' ', hl_group = 'DiagnosticWarn', firstc = false },
            [':'] = { icon = ' ﲵ', hl_group = 'DiagnosticError', firstc = false },
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
