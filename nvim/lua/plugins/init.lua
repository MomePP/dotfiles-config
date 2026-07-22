return {
    -- Core Dependencies
    { 'nvim-lua/plenary.nvim' },
    { 'MunifTanjim/nui.nvim' },
    {
        'nvim-mini/mini.icons',
        opts = {},
        init = function()
            package.preload['nvim-web-devicons'] = function()
                require('mini.icons').mock_nvim_web_devicons()
                return package.loaded['nvim-web-devicons']
            end
        end,
    },

    -- Utilities
    {
        'nmac427/guess-indent.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        config = true
    },
    {
        'nvim-mini/mini.surround',
        main = 'mini.surround',
        event = 'VeryLazy',
        config = true
    },
    {
        'Wansmer/treesj',
        dependencies = 'nvim-treesitter/nvim-treesitter',
        opts = {
            use_default_keymaps = false,
        },
        keys = {
            { require('config.keymaps').treesj.toggle, '<Cmd>TSJToggle<CR>' },
        }
    },
    {
        'serhez/bento.nvim',
        event = 'VeryLazy',
        opts = {
            max_open_buffers = 20,
            ui = {
                floating = {
                    max_rendered_buffers = 10,
                }
            },
            lock_char = require('config').defaults.icons.bento.pinned,
        },
    },
    {
        'saecki/live-rename.nvim',
        config = true,
        keys = function()
            local rename_keymap = require('config.keymaps').rename
            return {
                { rename_keymap.rename,       function() require('live-rename').rename({ insert = true }) end },
                { rename_keymap.rename_clean, function() require('live-rename').rename({ text = '', insert = true }) end },
            }
        end
    },

    -- Miscellaneous
    {
        'RaafatTurki/hex.nvim',
        cmd = { 'HexToggle', 'HexDump', 'HexAssemble' },
        config = true,
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-mini/mini.icons',
        },
        event = 'VeryLazy',
        opts = {
            file_types = { 'markdown' },
            anti_conceal = {
                enabled = false,
            },
            code = {
                position = 'right',
                width = 'block',
                border = 'thick',
                left_pad = 2,
                right_pad = 2,
            },
            pipe_table = {
                preset = 'round'
            },
        }
    }
}
