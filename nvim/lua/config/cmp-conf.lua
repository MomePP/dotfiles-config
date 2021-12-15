local cmp = require('cmp')
local lspkind = require('lspkind')
local utils = require('utils')

utils.opt('o', 'completeopt', 'menuone,noinsert,noselect')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = {
    { name = 'nvim_lua' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer', keyword_length = 3 },
  },
  formatting = {
    format = lspkind.cmp_format {
      with_text = true,
      maxwidth = 80,
      menu = {
        buffer = "[Buf]",
        nvim_lua = "[API]",
        nvim_lsp = "[LSP]",
        path = "[path]",
        luasnip = "[snip]",
      }
    }
  },
  experimental = {
    native_menu = false,
    ghost_text = true,
  }
})

vim.cmd [[highlight! default link CmpItemKind CmpItemMenuDefault]]

