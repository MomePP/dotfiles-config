local M = {
    'saghen/blink.cmp',
    build = function()
        require('blink.cmp').build():pwait()
        require('blink_linkedit_fix')('blink.cmp')
    end,
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
        { 'saghen/blink.lib' },
        { 'rafamadriz/friendly-snippets' },
        { 'fang2hou/blink-copilot',      opts = { max_completions = 2 } },
    },
}

M.opts = {
    keymap = {
        ['<Tab>'] = {
            'snippet_forward',
            function(cmp)
                return cmp.select_next({ on_ghost_text = true })
            end,
            'fallback'
        },
        ['<S-Tab>'] = {
            'snippet_backward',
            function(cmp)
                return cmp.select_prev({ on_ghost_text = true })
            end,
            'fallback',
        },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-e>'] = { 'cancel', 'fallback' },
        ['<M-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
    },
    completion = {
        list = {
            max_items = 50,
            selection = {
                preselect = true,
                auto_insert = false,
            }
        },
        menu = {
            auto_show = false,
            winblend = vim.opt.pumblend:get(),
            winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu',
            scrollbar = false,
            draw = {
                gap = 2,
                columns = { { 'kind_icon' }, { 'label', 'label_description', gap = 1 }, { 'kind' } },
            },
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 250,
            window = {
                winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu,BlinkCmpDocSeparator:Pmenu',
            }
        },
        ghost_text = { enabled = true }
    },
    signature = {
        enabled = false,
    },
    appearance = {
        nerd_font_variant = 'mono'
    },
    cmdline = {
        keymap = {
            ['<C-e>'] = { 'cancel', 'fallback' },
            ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
            ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },
        },
        completion = {
            list = {
                selection = {
                    preselect = true,
                    auto_insert = true,
                }
            },
            menu = { auto_show = false },
            ghost_text = { enabled = true },
        },
    },
    sources = {
        default = { 'copilot', 'lsp', 'buffer', 'snippets', 'path' },
        providers = {
            buffer = {
                opts = { enable_in_ex_commands = true }
            },
            copilot = {
                name = 'copilot',
                module = 'blink-copilot',
                score_offset = 100,
                async = true,
            },
        }
    }
}

return M
