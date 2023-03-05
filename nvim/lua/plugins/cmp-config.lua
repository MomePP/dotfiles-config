local M = {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        -- 'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-path',
        'saadparwaiz1/cmp_luasnip',
        'lukas-reineke/cmp-rg',

        -- NOTE: snippet plugins
        {
            'L3MON4D3/LuaSnip',
            dependencies = {
                'rafamadriz/friendly-snippets',
                config = function()
                    require('luasnip.loaders.from_vscode').lazy_load()
                end,
            },
            opts = {
                history = true,
                delete_check_events = 'TextChanged',
            }
        },
        -- {
        --     'jcdickinson/codeium.nvim',
        --     dependencies = { 'plenary', 'nui' },
        --     config = true,
        -- },

        -- NOTE: autopairs plugin
        {
            'windwp/nvim-autopairs',
            opts = { check_ts = true, fast_wrap = { map = '<C-e>' } },
        },
    },
}

M.opts = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local icons = require('config').defaults.icons

    local ELLIPSIS_CHAR = ' …'
    local MAX_LABEL_WIDTH = 50
    local MIN_LABEL_WIDTH = 10

    local function has_words_before()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
    end

    local cmp_formatting = {
        -- fields = { 'abbr', 'kind', 'menu' },
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
            local label = vim_item.abbr
            local truncated_label = vim.fn.strcharpart(label, 0, MAX_LABEL_WIDTH)
            if truncated_label ~= label then
                vim_item.abbr = truncated_label .. ELLIPSIS_CHAR
            elseif string.len(label) < MIN_LABEL_WIDTH then
                local padding = string.rep(' ', MIN_LABEL_WIDTH - string.len(label))
                vim_item.abbr = label .. padding
            end
            vim_item.kind = string.format(' %s ', icons.cmp.kinds[vim_item.kind])
            vim_item.menu = string.format(icons.cmp.source_format .. '%s', entry.source.name)
            return vim_item
        end,
    }

    local cmp_mapping = {
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
        ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs( -2), { 'i', 'c' }),
        ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
        ['<C-e>'] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
        ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable( -1) then
                luasnip.jump( -1)
            else
                fallback()
            end
        end, { 'i', 's' }),
    }

    local cmp_sources = cmp.config.sources({
        { name = 'nvim_lsp', keyword_length = 2 },
        { name = 'luasnip',  keyword_length = 2 },
        -- { name = 'codeium',  keyword_length = 2 },
        -- { name = 'buffer' },
        { name = 'rg' },
        { name = 'path' },
    })

    return {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end, },
        mapping = cmp_mapping,
        sources = cmp_sources,
        formatting = cmp_formatting,
        window = {
            completion = {
                col_offset = -3,
                side_padding = 0,
            },
        },
        experimental = {
            ghost_text = true
        },
        completion = {
            keyword_length = 3,
        },
        matching = {
            disallow_partial_fuzzy_matching = false
        },
    }
end

M.config = function(_, opts)
    local cmp = require('cmp')

    cmp.setup(opts)

    cmp.setup.cmdline({ '/', '?' }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            -- { name = 'buffer' }
            { name = 'rg' }
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

    -- NOTE: autopairs mapping on <CR>
    cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
end

return M
