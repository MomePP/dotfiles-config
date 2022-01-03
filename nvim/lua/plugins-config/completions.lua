local cmp_loadded, cmp = pcall(require, 'cmp')
if not cmp_loadded then return end

local snip_loadded, luasnip = pcall(require, 'luasnip')
if not snip_loadded then return end

local utils = require('utils')

-- utils.opt('o', 'completeopt', 'menuone,noinsert,noselect')
utils.opt('o', 'completeopt', 'menu,menuone,noselect')

require('luasnip/loaders/from_vscode').lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local lspkind_icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "",
  Field = "ﰠ",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "塞",
  Value = "",
  Enum = "",
  Keyword = "",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "פּ",
  Event = "",
  Operator = "",
  TypeParameter = ""
}

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>'] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' })
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer', keyword_length = 3 },
    { name = 'nvim_lua' },
    { name = 'path' },
  },
  formatting = {
    fields = { 'abbr', 'menu', 'kind' },
    format = function (entry, vim_item)
      vim_item.kind = string.format("%s", lspkind_icons[vim_item.kind])
      -- vim_item.kind = string.format("%s %s", lspkind_icons[vim_item.kind], vim_item.kind)
      vim_item.menu = ({
        nvim_lua = "[Lua]",
        nvim_lsp = "[LSP]",
        buffer = "[Buffer]",
        path = "[Path]",
        luasnip = "[Snippets]"
      }) [entry.source.name]
      return vim_item
    end
  },
  documentation = {
    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  }
})

vim.cmd [[highlight! default link CmpItemKind CmpItemMenuDefault]]

