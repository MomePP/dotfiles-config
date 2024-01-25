local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        {
            'nvim-treesitter/nvim-treesitter-context',
            opts = { zindex = 5, max_lines = 3 },
        },
        {
            'vidocqh/auto-indent.nvim',
            opts = {
                indentexpr = function(lnum)
                    return require('nvim-treesitter.indent').get_indent(lnum)
                end
            }
        },
        'windwp/nvim-ts-autotag',
        'nvim-treesitter-textobjects',
    },
    main = 'nvim-treesitter.configs'
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
            'tsx',
            'javascript',
            'css',
            'scss',
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
            enable = true,
            disable = { 'cpp' }
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

return M
