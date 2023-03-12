return {
    { 'nvim-lua/plenary.nvim',       lazy = false },
    { 'MunifTanjim/nui.nvim',        lazy = false },
    { 'nvim-tree/nvim-web-devicons', lazy = false },

    -- Utilities
    {
        'tzachar/local-highlight.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = { hlgroup = 'LocalHighlightText', cw_hlgroup = 'LocalHighlightText' },
    },
    {
        'nmac427/guess-indent.nvim',
        event = { 'BufReadPost', 'BufNewFile' },
        config = true
    },
    {
        'Maan2003/lsp_lines.nvim',
        dependencies = 'nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
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
        event = { 'BufReadPost', 'BufNewFile' },
        opts = {
            delay = 200,
            excluded_filetypes = {
                [''] = true,
                ['toggleterm'] = true,
            }
        }
    },


    -- Miscellaneous
    { 'RaafatTurki/hex.nvim', cmd = { 'HexToggle', 'HexDump', 'HexAssemble' }, config = true },
}
