local M = {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
}

M.config = function()
  local autopairs = require('nvim-autopairs')
  local autopairs_keymap = require('keymaps').autopair

  autopairs.setup({
    check_ts = true,
    ts_config = {
      lua = { 'string', 'source' },
      javascript = { 'string', 'template_string' },
      java = false,
    },
    disable_filetype = { 'TelescopePrompt', 'toggleterm' },
    fast_wrap = {
      map = autopairs_keymap.wrap,
      chars = { "{", "[", "(", '"', "'" },
      pattern = string.gsub([[ [%'%'%)%>%]%)%}%,] ]], '%s+', ''),
      end_key = '$',
      keys = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma = true,
      highlight = 'Search',
      highlight_grey = 'Comment'
    },
  })

  local cmp_status_ok, cmp = pcall(require, 'cmp')
  if not cmp_status_ok then return end
  local cmp_autopairs = require 'nvim-autopairs.completion.cmp'

  cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done { filetypes = { tex = false } })
end

return M
