return {
    { 'nvim-lua/plenary.nvim', lazy = false },
    { 'MunifTanjim/nui.nvim', lazy = false },
    { 'nvim-tree/nvim-web-devicons', lazy = false },

    -- Utilities
    { 'nmac427/guess-indent.nvim', event = 'BufReadPost', config = true },
    { 'Maan2003/lsp_lines.nvim', dependencies = 'nvim-lspconfig', event = 'BufReadPost', config = true },

    -- Miscellaneous
    { 'RaafatTurki/hex.nvim', cmd = { 'HexToggle', 'HexDump', 'HexAssemble' }, config = true },
}
