local M = {
    'folke/noice.nvim',
    event = 'VeryLazy'
}

M.keys = function()
    local noice_docs = require('noice.lsp')
    local noice_keymaps = require('config.keymaps').noice

    return {
        { noice_keymaps.history, '<Cmd>Noice<CR>' },
        {
            noice_keymaps.docs_scroll_down,
            function()
                if not noice_docs.scroll(4) then
                    return noice_keymaps.docs_scroll_down
                end
            end,
            silent = true, expr = true,
        },
        {
            noice_keymaps.docs_scroll_up,
            function()
                if not noice_docs.scroll(-4) then
                    return noice_keymaps.docs_scroll_up
                end
            end,
            silent = true, expr = true,
        },
    }
end

M.opts = {
    views = {
        hover = {
            focusable = false,
            border = {
                style = 'none',
                padding = { 1, 2 },
            },
            position = { row = 2, col = 0 },
            win_options = {
                wrap = true,
                linebreak = true,
                winhighlight = {
                    Normal = 'NormalFloat',
                    FloatBorder = 'FloatBorder',
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
            calculator = { icon = ' CALCULATOR ', icon_hl_group = 'NoiceCmdlineIconFilter' },
            lua = false,
        }
    },
    popupmenu = {
        backend = 'cmp',
    },
    commands = {
        history = {
            filter_opts = { reverse = true }
        }
    },
    lsp = {
        hover = { enabled = true, },
        signature = { enabled = true },
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        }
    },
}

return M
