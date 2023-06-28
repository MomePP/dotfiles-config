-- INFO: lazy.nvim bootstrap checking
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- INFO: lazy.nvim configs
local default_config = require('config').defaults

local lazy_config = {
    defaults = {
        lazy = true
    },
    performance = {
        install = {
            colorscheme = { 'nvim-colorscheme', 'habamax' }
        },
        ui = {
            border = default_config.float_border
        },
        rtp = {
            disabled_plugins = {
                '2html_plugin',
                'getscript',
                'getscriptPlugin',
                'gzip',
                'logipat',
                'netrw',
                'netrwPlugin',
                'netrwSettings',
                'netrwFileHandlers',
                'matchit',
                'matchparen',
                'tar',
                'tarPlugin',
                'tohtml',
                'tutor',
                'rrhelper',
                'vimball',
                'vimballPlugin',
                'zip',
                'zipPlugin',
            },
        },
    },
    dev = {
        path = '~/Developments/nvim-plugins'
    }
}
require('lazy').setup('plugins', lazy_config)

-- INFO: lazy.nvim keybinding
local lazy_keymap = require('config.keymaps').lazy
vim.keymap.set('n', lazy_keymap.open, '<Cmd>Lazy<CR>')

-- INFO: fix double virtual texts
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'lazy',
    callback = function()
        local floating = vim.api.nvim_win_get_config(0).relative ~= ''
        vim.diagnostic.config({
            virtual_text = floating,
            virtual_lines = not floating,
        })
    end,
})
