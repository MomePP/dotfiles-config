local Plug = vim.fn['plug#']

-- set `.local/share/nvim/plugged` as main plugin directory
vim.g.plug_home = vim.fn.stdpath('data') .. '/plugged'

vim.call('plug#begin', vim.g.plug_home)

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'neovim/nvim-lspconfig'
Plug 'onsails/lspkind-nvim'
Plug 'glepnir/lspsaga.nvim'
Plug 'L3MON4D3/LuaSnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug ('nvim-treesitter/nvim-treesitter', {['do'] = function() vim.cmd 'TSUpdate' end})
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzy-native.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'windwp/nvim-autopairs'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'hoob3rt/lualine.nvim'
Plug 'numToStr/Comment.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'alvarosevilla95/luatab.nvim'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'MomePP/plastic-nvim'

vim.call('plug#end')

