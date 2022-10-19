local noice_status, noice = pcall(require, 'noice')
if not noice_status then return end

local colors = require('colorscheme').colorset

-- override highlight group for Noice cmdline
vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', { bg = colors.transparent, fg = colors.red, bold = true })
vim.api.nvim_set_hl(0, 'NoiceCmdlineIconSearch', { bg = colors.transparent, fg = colors.orange, bold = true })

noice.setup {
    views = {
        mini = {
            focusable = false,
            timeout = 3000,
        },
    },
    cmdline = {
        view = 'cmdline',
        view_search = 'cmdline',
        icons = {
            ['?'] = { icon = ' SEARCH ', firstc = false },
            ['/'] = { icon = ' SEARCH ', firstc = false },
            [':'] = { icon = ' COMMAND ', firstc = false },
        },
    },
    popupmenu = {
        enable = false,
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
                    { event = { 'notify', 'noice', 'lsp' } },
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
