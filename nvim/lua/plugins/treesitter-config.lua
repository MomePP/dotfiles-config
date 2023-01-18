local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',

    dependencies = {
        'windwp/nvim-ts-autotag',
        'mrjones2014/nvim-ts-rainbow',
    }
}

M.opts = {
    ensure_installed = { 'regex', 'lua', 'vim', 'markdown', 'markdown_inline', 'bash', 'fish' },
    auto_install = true,
    sync_install = false,
    ignore_install = {
        'norg',
        'vala'
    },
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = true
    },
    context_commentstring = {
        enable = true,
        enable_autocmd = false,
    },
    rainbow = {
        enable = true,
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        colors = require('plugins.colorscheme').colorset.bracket,
    },
    autotag = {
        enable = true,
    },
}

M.config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)
end

return M
