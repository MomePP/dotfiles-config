local M = {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
        -- NOTE: cmp sources
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-cmdline',
        'FelipeLema/cmp-async-path',
        {
            'tzachar/cmp-fuzzy-buffer',
            dependencies = { 'tzachar/fuzzy.nvim' },
        },

        -- NOTE: snippet plugins
        {
            'saadparwaiz1/cmp_luasnip',
            dependencies = {
                {
                    'rafamadriz/friendly-snippets',
                    config = function()
                        require('luasnip.loaders.from_vscode').lazy_load()
                    end,
                },
                {
                    'L3MON4D3/LuaSnip',
                    opts = {
                        history = true,
                        enable_autosnippets = true,
                        region_check_events = 'InsertEnter',
                        delete_check_events = 'TextChanged,InsertLeave',
                    }
                }
            },
        },

        -- NOTE: autopairs plugin
        {
            'windwp/nvim-autopairs',
            opts = { check_ts = true, fast_wrap = { map = '<C-e>' } },
        },

        -- NOTE: github copilot if available
        {
            'zbirenbaum/copilot-cmp',
            dependencies = {
                'zbirenbaum/copilot.lua',
                opts = {
                    suggestion = { enabled = false },
                    panel = { enabled = false },
                }
            },
            config = true
        },

        -- NOTE: misc. plugins
        'onsails/lspkind.nvim',
    },
}

M.opts = function()
    local default_border = require('config').defaults.float_border

    local cmp = require('cmp')
    local luasnip = require('luasnip')

    local lspkind_format = require('lspkind').cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
        symbol_map = { Copilot = '' },
    })

    local function has_word_before()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match('%s') == nil
    end

    local cmp_formatting = {
        fields = { 'kind', 'abbr', 'menu' },
        format = function(entry, vim_item)
            local original_kind = vim_item.kind
            local kind = lspkind_format(entry, vim_item)
            local strings = vim.split(kind.kind, '%s', { trimempty = true })

            kind.kind = strings[1] .. ' '
            kind.menu = '   ' .. strings[2]
            kind.menu_hl_group = 'CmpItemKind' .. original_kind

            return kind
        end,
    }

    local cmp_mapping = {
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
        ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-2), { 'i', 'c' }),
        ['<C-e>'] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
        ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            else
                fallback()
            end
        end),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_word_before() then
                cmp.complete()
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
        end, { 'i', 's' }),
    }

    local cmp_sorting = {
        priority_weight = 2,
        comparators = {
            require('copilot_cmp.comparators').prioritize,
            require('cmp_fuzzy_buffer.compare'),

            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,

            -- INFO: sort by number of underscores
            function(entry1, entry2)
                local _, entry1_under = entry1.completion_item.label:find "^_+"
                local _, entry2_under = entry2.completion_item.label:find "^_+"
                entry1_under = entry1_under or 0
                entry2_under = entry2_under or 0
                if entry1_under > entry2_under then
                    return false
                elseif entry1_under < entry2_under then
                    return true
                end
            end,

            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    }

    local cmp_sources = cmp.config.sources(
        {
            { name = 'copilot' },
            { name = 'async_path' },
            { name = 'nvim_lsp' },
            { name = 'luasnip',   keyword_length = 2 },
        },
        {
            { name = 'fuzzy_buffer', option = { min_match_length = 2 } },
        }
    )

    return {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp_mapping,
        sorting = cmp_sorting,
        sources = cmp_sources,
        formatting = cmp_formatting,
        window = {
            completion = {
                col_offset = -4,
                side_padding = 1,
                border = default_border,
            },
            documentation = {
                border = default_border,
            }
        },
        experimental = {
            ghost_text = { hl_group = 'Comment' }
        },
        preselect = cmp.PreselectMode.Item,
        completion = {
            completeopt = 'menuone',
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
        completion = {
            completeopt = 'menuone,noselect',
        },
        sources = {
            { name = 'fuzzy_buffer', option = { min_match_length = 2 } },
        }
    })

    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        completion = {
            completeopt = 'menuone,noselect',
        },
        sources = cmp.config.sources({
            { name = 'async_path' }
        }, {
            { name = 'cmdline' }
        })
    })

    -- NOTE: autopairs mapping on <CR>
    cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
end

return M
