return {
    'nvim-lua/plenary.nvim',
    'nvim-lua/popup.nvim',
    'MunifTanjim/nui.nvim',
    'kyazdani42/nvim-web-devicons',

    -- Utilities
    { 'moll/vim-bbye', event = 'VeryLazy' },
    { 'fedepujol/move.nvim', event = 'VeryLazy' },
    { 'Maan2003/lsp_lines.nvim', event = 'VeryLazy', config = true },
    { 'nmac427/guess-indent.nvim', event = 'BufReadPost', config = true },
    { 'iamcco/markdown-preview.nvim', cmd = { 'MarkdownPreviewToggle' }, build = function() vim.fn['mkdp#util#install']() end },

    -- Color Schemes
    'rebelot/kanagawa.nvim',
}
