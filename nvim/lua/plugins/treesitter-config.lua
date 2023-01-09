local M = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    event = 'BufReadPost',

    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
        'windwp/nvim-ts-autotag',
        'p00f/nvim-ts-rainbow',
    }
}

M.config = function()
    local treesitter = require('nvim-treesitter.configs')
    local bracket_colors = require('colorscheme').colorset.bracket

    treesitter.setup {
        highlight = {
            enable = true,
            disable = {},
            additional_vim_regex_highlighting = false,
        },
        indent = { enable = false },
        ensure_installed = { 'regex', 'lua', 'vim', 'markdown', 'markdown_inline', 'bash', 'fish' },
        auto_install = true,
        sync_install = false,
        ignore_install = {
            'norg',
            'vala'
        },
        rainbow = {
            enable = true,
            extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
            max_file_lines = nil, -- Do not enable for files with more than n lines, int
            colors = bracket_colors,
        },
        autotag = {
            enable = true,
        },
        context_commentstring = {
            enable = true,
            enable_autocmd = false,
        },
        textobjects = {
            select = {
                enable = true
            },
            move = {
                enable = true
            }
        }
    }
end

return M
