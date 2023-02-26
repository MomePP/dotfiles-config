local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
        'nvim-ts-context-commentstring',
        'windwp/nvim-ts-autotag',
        'HiPhish/nvim-ts-rainbow2',
    }
}

M.opts = {
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
        enable = true,
        disable = { 'python' },
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
        enable = true
    }
}

M.config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
end

return M
