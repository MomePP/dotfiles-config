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
        'Maan2003/lsp_lines.nvim',
        dependencies = 'nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
        config = true
    },
    {
        'SmiteshP/nvim-navic',
        dependencies = 'nvim-lspconfig',
        event = { 'BufReadPost', 'BufNewFile' },
        opts = { separator = '  ', highlight = true }
    },

    -- Miscellaneous
    { 'RaafatTurki/hex.nvim', cmd = { 'HexToggle', 'HexDump', 'HexAssemble' }, config = true },
}
