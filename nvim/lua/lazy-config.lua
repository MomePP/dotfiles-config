-- INFO: lazy.nvim bootstrap checking
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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
local default_border = require('config').defaults.float_border

local lazy_config = {
    defaults = {
        lazy = true
    },
    performance = {
        install = {
            colorscheme = { 'nvim-colorscheme', 'habamax' }
        },
        ui = {
            border = default_border
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
