-- INFO: lazy.nvim bootstrap checking
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        'git',
        'clone',
        '--filter=blob:none',
        '--single-branch',
        'https://github.com/folke/lazy.nvim.git',
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- INFO: lazy.nvim configs
local lazy_config = {
    defaults = {
        lazy = true
    },
    performance = {
        ui = {
            border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' }
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
    }
}
require('lazy').setup('plugins', lazy_config)

-- INFO: lazy.nvim keybinding
local lazy_keymap = require('keymaps').lazy
vim.keymap.set('n', lazy_keymap.open, '<Cmd>Lazy<CR>', lazy_keymap.opts)
