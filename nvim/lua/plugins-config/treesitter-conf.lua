local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end

treesitter.setup {
  highlight = {
    enable = true,
    disable = {},
    additional_vim_regex_highlighting = true,
  },
  indent = {
    enable = false,
    disable = { 'yaml' },
  },
  ensure_installed = "maintained",
  sync_install = true,
  ignore_install = false
}

