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

vim.keymap.set('n', lazy_keymap.lazygit, function()
    require('lazy.util').open_cmd({ 'lazygit' }, {
        terminal = true,
        close_on_exit = true,
        enter = true,
        float = {
            size = { width = 0.9, height = 0.85 },
            margin = { top = -1, right = 0, bottom = 0, left = 0 },
            win_opts = {
                border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', }
            }
        },
    })
end, { desc = 'Lazygit' })
