local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'JoosepAlviste/nvim-ts-context-commentstring',
        'windwp/nvim-ts-autotag',
        'HiPhish/nvim-ts-rainbow2',
    }
}

M.opts = function()
    local keymaps = require('config.keymaps').treesitter
    return {
        ensure_installed = {
            'regex',
            'lua',
            'vim',
            'markdown',
            'markdown_inline',
            'bash',
            'fish',
            'help',
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
            -- disable = { 'python' },
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
        rainbow = {
            enable = true,
            -- max_file_lines = nil, -- Do not enable for files with more than n lines
            -- colors = require('plugins.colorscheme').colorset.bracket
        },
        autotag = {
            enable = true,
        },
        incremental_selection = {
            enable = true,
            keymaps = keymaps.incremental_selection,
        },
    }
end

M.config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
end

return M
