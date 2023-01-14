return {
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    'kyazdani42/nvim-web-devicons',

    -- Utilities
    { 'nmac427/guess-indent.nvim', event = 'BufReadPost', config = true },
    { 'Maan2003/lsp_lines.nvim', dependencies = 'nvim-lspconfig', event = 'BufReadPost', config = true },
}
