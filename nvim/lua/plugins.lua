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

    -- git plugins
    use 'lewis6991/gitsigns.nvim'

    -- LSP
    use 'neovim/nvim-lspconfig'
    use 'williamboman/nvim-lsp-installer'

    -- snippets
    use 'L3MON4D3/LuaSnip'
    use 'rafamadriz/friendly-snippets'

    -- cmp plugins
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'saadparwaiz1/cmp_luasnip'

    -- telescope
    use 'nvim-telescope/telescope.nvim'
    use 'nvim-telescope/telescope-file-browser.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make'}

    -- utilities
    use 'windwp/nvim-autopairs'
    use { 'norcalli/nvim-colorizer.lua', event = 'BufRead' }
    use { 'lukas-reineke/indent-blankline.nvim', event = 'BufRead' }
    use { 'numToStr/Comment.nvim', config = function() require('Comment').setup() end }
    use { 'ellisonleao/glow.nvim', config = function () vim.g.glow_border = "rounded" end }
    use 'akinsho/toggleterm.nvim'

    -- UI decoration
    use { 'kyazdani42/nvim-web-devicons', config = function() require('nvim-web-devicons').setup() end }
    use { 'alvarosevilla95/luatab.nvim', after = 'nvim-web-devicons' }
    use { 'hoob3rt/lualine.nvim', after = 'nvim-web-devicons' }
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
    use 'p00f/nvim-ts-rainbow'
    use 'folke/zen-mode.nvim'
    use 'folke/todo-comments.nvim'
    -- use 'MomePP/plastic-nvim'
    use 'rebelot/kanagawa.nvim'

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

