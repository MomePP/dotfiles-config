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
            focusable = false,
            timeout = 3000,
        },
    },
    messages = {
        view_search = false,
    },
    cmdline = {
        view = 'cmdline',
        format = {
            cmdline = { pattern = '^:', icon = ' COMMAND ' },
            search = { pattern = '^[?/]', icon = ' SEARCH ', conceal = true },
            filter = { pattern = '^:%s*!', icon = ' BASH ', opts = { buf_options = { filetype = 'sh' } } },
            lua = false,
        }
    },
    popupmenu = {
        enable = true,
        backend = 'cmp',
    },
    lsp_progress = {
        enable = true,
    },
}
