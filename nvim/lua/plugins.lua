return {
    'nvim-lua/plenary.nvim',
    'nvim-lua/popup.nvim',
    'MunifTanjim/nui.nvim',
    'kyazdani42/nvim-web-devicons',

    -- Utilities
    { 'fedepujol/move.nvim', event = 'BufReadPost' },
    { 'Maan2003/lsp_lines.nvim', event = 'BufReadPost', config = true },
    { 'nmac427/guess-indent.nvim', event = 'BufReadPost', config = true },
    { 'echasnovski/mini.pairs', event = 'InsertEnter', config = function() require('mini.pairs').setup({}) end },

    -- Color Schemes
    'rebelot/kanagawa.nvim',
}
