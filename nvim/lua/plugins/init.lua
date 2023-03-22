return {
    { 'nvim-lua/plenary.nvim',       lazy = false },
    { 'MunifTanjim/nui.nvim',        lazy = false },
    { 'nvim-tree/nvim-web-devicons', lazy = false },

    -- Utilities
    {
        'nmac427/guess-indent.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        config = true
    },
    {
        'tzachar/local-highlight.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = { hlgroup = 'LocalHighlightText', cw_hlgroup = 'LocalHighlightText' },
    },
    {
        'kylechui/nvim-surround',
        dependencies = { 'nvim-treesitter-textobjects' },
        event = 'VeryLazy',
        config = true
    },
    {
        'SmiteshP/nvim-navic',
        dependencies = 'nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = { separator = '  ', highlight = true },
    },
    {
        'Wansmer/treesj',
        dependencies = { 'nvim-treesitter' },
        opts = {
            use_default_keymaps = false,
        },
        keys = {
            { require('config.keymaps').treesj.toggle, '<Cmd>TSJToggle<CR>' },
        }
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            char = '│',
            show_trailing_blankline_indent = false,
            show_current_context = true,
        }
    },
    {
        'utilyre/sentiment.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            excluded_filetypes = {
                [''] = true,
                ['toggleterm'] = true,
            }
        }
    },


    -- Miscellaneous
    { 'RaafatTurki/hex.nvim', cmd = { 'HexToggle', 'HexDump', 'HexAssemble' }, config = true },
}
