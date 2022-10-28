local noice_status, noice = pcall(require, 'noice')
if not noice_status then return end

local colors = require('colorscheme').colorset

-- override highlight group for Noice cmdline
vim.api.nvim_set_hl(0, 'NoiceCmdlineIconCmdline', { bg = colors.transparent, fg = colors.red, bold = true })
vim.api.nvim_set_hl(0, 'NoiceCmdlineIconSearch', { bg = colors.transparent, fg = colors.orange, bold = true })
vim.api.nvim_set_hl(0, 'NoiceCmdlineIconFilter', { bg = colors.transparent, fg = colors.teal, bold = true })

noice.setup {
    views = {
        mini = {
            reverse = false,
            focusable = false,
            timeout = 3000,
        },
        hover = {
            focusable = false,
            border = {
                style = 'none',
                padding = { 0, 2 },
            },
            position = { row = 1, col = 0 },
            win_options = {
                wrap = true,
                linebreak = true,
                winhighlight = {
                    Normal = 'Pmenu',
                    FloatBorder = 'Pmenu',
                    Search = 'NONE',
                }
            },
        },
    },
    messages = {
        view_search = false,
    },
    cmdline = {
        view = 'cmdline',
        format = {
            cmdline = { icon = ' COMMAND ' },
            search_down = { icon = ' SEARCH  ' },
            search_up = { icon = ' SEARCH  ' },
            filter = { icon = ' TERMINAL ', lang = 'fish' },
            lua = false,
        }
    },
    popupmenu = {
        backend = 'cmp',
    },
    lsp = {
        hover = { enabled = true, },
        signature = { enabled = true },
    },
}
