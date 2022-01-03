local status_ok, blankline = pcall(require, 'indent_blankline')
if not status_ok then return end

blankline.setup {
  indentLine_enabled = 1,
  filetype_exclude = {
    'help',
    'terminal',
    'packer',
    'lspinfo',
    'TelescopePrompt',
    'TelescopeResults',
    ''
  },
  buftype_exclude = { 'terminal' },
  show_tailing_blankline_indent = false,
  show_first_indent_level = false,
}
