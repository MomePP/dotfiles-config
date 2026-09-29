local M = {
    'https://forge.barrettruth.com/barrettruth/canola.nvim',
    dependencies = 'nvim-mini/mini.icons',
    main = 'oil'
}

M.opts = {
    diff_mode = true,
    columns = {
        'permissions',
        'size',
        'mtime',
        'icon',
    },
    view_options = {
        show_hidden = true,
    },
    float = {
        border = 'solid',
        override = function(conf)
            conf.width = vim.o.columns - 2 -- NOTE: this offset cause by padding = 2
            conf.height = vim.o.lines - 3
            conf.col = 0
            conf.row = 0
            return conf
        end,
        win_options = {
            winhighlight = 'Normal:NormalFloat,FloatTitle:OilTitle',
            winblend = vim.opt.winblend:get(),
        },
        get_win_title = function(_)
            return ''
        end,
        preview_split = 'right',
    },
    preview_win = {
        win_options = {
            winhighlight = 'Normal:OilPreviewNormal,FloatBorder:OilPreviewBorder,FloatTitle:OilPreviewTitle',
        },
    },
    keymaps = {
        ['<Space>'] = 'actions.close',
        ['q'] = 'actions.close',
        ['<C-u>'] = 'actions.preview_scroll_up',
        ['<C-d>'] = 'actions.preview_scroll_down',
        ['<C-y>'] = 'actions.copy_to_system_clipboard',
        ['<C-p>'] = 'actions.paste_from_system_clipboard',
        ['<C-o>'] = {
            callback = function()
                local dir = require('oil').get_current_dir()
                if not dir or not vim.ui.open then
                    return
                end

                vim.ui.open(dir)
            end,
            desc = 'Reveal directory'
        },
    }
}

M.keys = function()
    local oil_keymap = require('config.keymaps').oil
    return {
        {
            oil_keymap.open_float,
            function()
                if vim.w.is_oil_win then
                    require('oil').close()
                else
                    require('oil').open_float(nil, { preview = {} })
                end
            end
        },
    }
end

return M
