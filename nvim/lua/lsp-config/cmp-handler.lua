local cmp_loaded, cmp = pcall(require, 'cmp')
if not cmp_loaded then return end

-- ----------------------------------------------------------------------
--  luasnip configs
--
local luasnip_loaded, luasnip = pcall(require, 'luasnip')
if not luasnip_loaded then return end

luasnip.config.set_config({
    region_check_events = 'InsertEnter',
    delete_check_events = 'InsertLeave'
})
require('luasnip.loaders.from_vscode').load()

-- ----------------------------------------------------------------------
--  cmp configs
--
local function check_backspace()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local cmp_icons = {
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

local cmp_menu_icon = {
    nvim_lsp = 'LSP',
    luasnip = 'Snippet',
    buffer = 'Buffer',
    path = 'Path',
    nvim_lua = 'Lua',
}

local cmp_mapping = {
    ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(1), { 'i', 'c' }),
    ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-1), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable,
    ['<C-e>'] = cmp.mapping {
        i = cmp.mapping.abort(),
        c = cmp.mapping.close()
    },
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
}

local cmp_sources = {
    { name = 'path' },
    { name = 'nvim_lua', keyword_length = 3 },
    { name = 'nvim_lsp', keyword_length = 3 },
    { name = 'buffer', keyword_length = 3 },
    { name = 'luasnip', keyword_length = 2 },
}

local cmp_configs = {
    snippet = { expand = function(args) luasnip.lsp_expand(args.body) end, },
    mapping = cmp_mapping,
    sources = cmp_sources,
    formatting = {
        fields = { 'abbr', 'kind' },
        format = function(entry, item)
            item.menu = cmp_menu_icon[entry.source.name]
            item.kind = string.format("%s %s", cmp_icons[item.kind], item.kind)
            return item
        end
    },
    window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered(),
    },
    experimental = {
        ghost_text = true
    },
    completion = {
        completeopt = 'menu,menuone,noinsert'
    }
}

cmp.setup(cmp_configs)
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- link cmp icons highlighting
vim.highlight.link('CmpItemKind', 'CmpItemMenuDefault')
