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
local default_config = require('config').defaults

local lazy_config = {
    defaults = {
        lazy = true
    },
    performance = {
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
    }
}
require('lazy').setup('plugins', lazy_config)

-- INFO: lazy.nvim keybinding
local lazy_keymap = require('config.keymaps').lazy
vim.keymap.set('n', lazy_keymap.open, '<Cmd>Lazy<CR>', lazy_keymap.opts)

vim.keymap.set('n', lazy_keymap.lazygit, function()
    require('lazy.util').float_term({ 'lazygit' }, {
        size = { width = 0.9, height = 0.85 },
        margin = { top = -2, bottom = 1, left = -2, right = 1 },
        border = default_config.float_border
    })
end, { desc = 'Lazygit' })
