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
        'altermo/ultimate-autopair.nvim',
        event = { 'InsertEnter', 'CmdlineEnter' },
        opts = { extensions = { { 'cmdtype', { '/', '?', '@', ':' } } } },
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

    -- Miscellaneous
    { 'RaafatTurki/hex.nvim', cmd = { 'HexToggle', 'HexDump', 'HexAssemble' }, config = true },
}
