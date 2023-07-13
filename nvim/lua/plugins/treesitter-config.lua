local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'nvim-treesitter/nvim-treesitter-context',
        'JoosepAlviste/nvim-ts-context-commentstring',
        'windwp/nvim-ts-autotag',
        'yioneko/nvim-yati',
        'yioneko/vim-tmindent',

        'rainbow-delimiters.nvim',
    }
}

M.opts = function()
    local keymaps = require('config.keymaps').treesitter
    return {
        ensure_installed = {
            'regex',
            'lua',
            'vim',
            'vimdoc',
            'markdown',
            'markdown_inline',
            'bash',
            'fish',
            'yaml',
        },
        ignore_install = {
            'norg',
            'vala'
        },
        auto_install = true,
        sync_install = false,
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        indent = {
            enable = false,
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
        autotag = {
            enable = true,
        },
        incremental_selection = {
            enable = true,
            keymaps = keymaps.incremental_selection,
        },
        yati = {
            enable = true,
            default_fallback = function (lnum, computed, bufnr)
                return require('tmindent').get_indent(lnum, bufnr) + computed
            end
        }
    }
end

M.config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
end

return M
