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
        override = {
            -- override the default lsp markdown formatter with Noice
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            -- override the lsp markdown formatter with Noice
            ['vim.lsp.util.stylize_markdown'] = true,
            -- override cmp documentation with Noice (needs the other options to work)
            ['cmp.entry.get_documentation'] = true,
        }
    },
}

local noice_keymaps = require('keymappings').noice
local noice_docs = require('noice.lsp.docs')

vim.keymap.set('n', noice_keymaps.history, '<Cmd>Noice<CR>', noice_keymaps.opts.silent)

vim.keymap.set('n', noice_keymaps.docs_scroll_down, function()
    if not noice_docs.scroll(4) then
        return noice_keymaps.docs_scroll_down
    end
end, noice_keymaps.opts.silent_expr)

vim.keymap.set('n', noice_keymaps.docs_scroll_up, function()
    if not noice_docs.scroll(-4) then
        return noice_keymaps.docs_scroll_up
    end
end, noice_keymaps.opts.silent_expr)
