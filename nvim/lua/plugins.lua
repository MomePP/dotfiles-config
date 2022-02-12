local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
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
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    -- git plugins
    use 'lewis6991/gitsigns.nvim'

    -- snippets
    use { 'L3MON4D3/LuaSnip',
        requires = { 'rafamadriz/friendly-snippets' },
    }

    -- cmp plugins
    use { 'hrsh7th/nvim-cmp', event = 'BufRead' }
    use {'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' }
    use {'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' }
    use {'hrsh7th/cmp-buffer', after = 'nvim-cmp' }
    use {'hrsh7th/cmp-path', after = 'nvim-cmp' }
    use {'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' }

    -- telescope
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    -- utilities
    use { 'lukas-reineke/indent-blankline.nvim', event = 'BufRead' }
    use { 'numToStr/Comment.nvim', event = 'BufRead', config = function() require('Comment').setup() end }
    use { 'norcalli/nvim-colorizer.lua', event = 'BufRead' }
    use { 'akinsho/bufferline.nvim', after = 'nvim-web-devicons' }
    use { 'moll/vim-bbye', after = 'bufferline.nvim' }
    use { 'iamcco/markdown-preview.nvim', run = 'cd app && yarn install' }
    use 'windwp/nvim-autopairs'
    use 'akinsho/toggleterm.nvim'
    use 'beauwilliams/focus.nvim'
    use 'chentau/marks.nvim'

    -- UI decoration
    use { 'kyazdani42/nvim-web-devicons', config = function() require('nvim-web-devicons').setup() end }
    use { 'hoob3rt/lualine.nvim', after = 'bufferline.nvim' }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        requires = {
            { "p00f/nvim-ts-rainbow", after = "nvim-treesitter", },
            { "windwp/nvim-ts-autotag", after = "nvim-treesitter", },
            { "JoosepAlviste/nvim-ts-context-commentstring", after = "nvim-treesitter", },
        }
    }
    use 'folke/zen-mode.nvim'
    use 'folke/todo-comments.nvim'
    -- use 'MomePP/plastic-nvim'
    use 'rebelot/kanagawa.nvim'

    -- misc. cool stuff
    use 'andweeb/presence.nvim' -- discord activity status

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
      require("packer").sync()
    end
  end,
  config = {
    compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua'
  }
})

