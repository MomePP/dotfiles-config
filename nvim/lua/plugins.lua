local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
    }
    print 'Installing packer close and reopen Neovim...'
    vim.cmd 'packadd packer.nvim'
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.api.nvim_create_augroup('packer_user_config', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    desc = 'Sync packer after modifying plugins.lua',
    group = 'packer_user_config',
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerSync'
})

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require('packer.util').float { border = 'rounded' }
        end,
    },
}

return packer.startup({
    function(use)
        use 'wbthomason/packer.nvim'
        use 'nvim-lua/plenary.nvim'
        use 'nvim-lua/popup.nvim'
        use 'lewis6991/impatient.nvim'

        -- LSP
        use {
            'junnplus/lsp-setup.nvim',
            requires = {
                -- LSP Support
                'neovim/nvim-lspconfig',
                'williamboman/mason.nvim',
                'williamboman/mason-lspconfig.nvim',
            }
        }
        use {
            'hrsh7th/nvim-cmp',
            requires = {
                -- Autocompletion
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'saadparwaiz1/cmp_luasnip',

                -- Snippets
                'L3MON4D3/LuaSnip',
                'rafamadriz/friendly-snippets',
            }
        }
        use 'RRethy/vim-illuminate'
        use { 'Maan2003/lsp_lines.nvim', config = function() require('lsp_lines').setup() end }

        -- Github co-pilot
        use { 'zbirenbaum/copilot.lua', event = 'InsertEnter',
            config = function()
                vim.schedule(function() require('lsp-config.copilot-handler') end)
            end
        }
        use { 'zbirenbaum/copilot-cmp', after = { 'copilot.lua' } }

        -- Git plugins
        use 'lewis6991/gitsigns.nvim'
        use { 'akinsho/git-conflict.nvim', tag = '*' }

        -- Telescope
        use 'nvim-telescope/telescope.nvim'
        use 'nvim-telescope/telescope-file-browser.nvim'
        use 'nvim-telescope/telescope-ui-select.nvim'
        use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

        -- Treesitter
        use { 'nvim-treesitter/nvim-treesitter',
            run = function()
                require('nvim-treesitter.install').update({ with_sync = true })
            end
        }
        use 'nvim-treesitter/nvim-treesitter-textobjects'
        use 'JoosepAlviste/nvim-ts-context-commentstring'
        use 'windwp/nvim-ts-autotag'
        use 'p00f/nvim-ts-rainbow'

        -- Terminal
        use 'akinsho/toggleterm.nvim'

        -- Window management
        use 'beauwilliams/focus.nvim'

        -- Session management
        use 'Shatur/neovim-session-manager'

        -- Utilities
        use 'moll/vim-bbye'
        use 'numToStr/Comment.nvim'
        use 'NvChad/nvim-colorizer.lua'
        use 'windwp/nvim-autopairs'
        use 'chentoast/marks.nvim'
        use 'fedepujol/move.nvim'
        use { 'ggandor/leap.nvim', config = function() require('leap').set_default_keymaps() end }
        use { 'iamcco/markdown-preview.nvim', run = function() vim.fn['mkdp#util#install']() end, }

        -- UI decoration
        use 'kyazdani42/nvim-web-devicons'
        use 'nvim-lualine/lualine.nvim'
        use 'folke/todo-comments.nvim'
        use 'kevinhwang91/nvim-hlslens'
        use 'lukas-reineke/indent-blankline.nvim'
        use 'b0o/incline.nvim'
        use 'SmiteshP/nvim-navic'
        use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }
        use { 'folke/noice.nvim', requires = { 'MunifTanjim/nui.nvim' } }
        use { 'Darazaki/indent-o-matic', config = function() require('indent-o-matic').setup {} end }

        -- Color Schemes
        -- use 'MomePP/plastic-nvim'
        use 'rebelot/kanagawa.nvim'

        -- misc. cool stuff
        -- use 'andweeb/presence.nvim' -- discord activity status
        -- use 'dstein64/vim-startuptime'

        -- Automatically set up your configuration after cloning packer.nvim
        -- Put this at the end after all plugins
        if PACKER_BOOTSTRAP then
            require('packer').sync()
        end
    end
})
