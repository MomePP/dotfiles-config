-- Automatically install packer
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

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.api.nvim_create_augroup('lazy_user_config', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    desc = 'Sync plugins after modifying lazy-config.lua or update plugins.lua',
    group = 'lazy_user_config',
    pattern = { 'lazy-config.lua', 'plugins.lua' },
    command = 'source <afile> | Lazy sync'
})

-- INFO: lazy configs
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
