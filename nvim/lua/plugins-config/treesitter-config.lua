local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end

local bracket_colors = require('colorscheme').colorset.bracket

treesitter.setup {
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false,
    },
    indent = {
        enable = false,
        disable = { 'yaml' },
    },
    auto_install = true,
    sync_install = false,
    ignore_install = {
        'norg',
        'vala'
    },
    rainbow = {
        enable = true,
        -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
        extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
        max_file_lines = nil, -- Do not enable for files with more than n lines, int
        colors = bracket_colors,
        -- termcolors = {} -- table of colour name strings
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
