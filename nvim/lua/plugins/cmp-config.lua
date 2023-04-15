local M = {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',
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

        -- NOTE: autopairs plugin
        {
            'windwp/nvim-autopairs',
            opts = { check_ts = true, fast_wrap = { map = '<C-e>' } },
        },

        -- NOTE: github copilot if available
        'copilot.lua'
    },
}

M.opts = function()
    local cmp = require('cmp')
    local luasnip = require('luasnip')
    local icons = require('config').defaults.icons
    local copilot_status, copilot_suggestion = pcall(require, 'copilot.suggestion')

    local ELLIPSIS_CHAR = ' …'
    local MAX_LABEL_WIDTH = 50
    local MIN_LABEL_WIDTH = 10

    local function is_line_empty()
        local col = vim.fn.col('.') - 1
        return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
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
            vim_item.menu = string.format(icons.cmp.source_format .. '%s', icons.cmp.source_menu[entry.source.name])
            return vim_item
        end,
    }

    local cmp_mapping = {
        ['<C-d>'] = cmp.mapping(cmp.mapping.scroll_docs(2), { 'i', 'c' }),
        ['<C-u>'] = cmp.mapping(cmp.mapping.scroll_docs(-2), { 'i', 'c' }),
        ['<C-e>'] = cmp.mapping {
            i = function()
                if cmp.visible() then
                    cmp.abort()
                elseif copilot_status and copilot_suggestion.is_visible() then
                    copilot_suggestion.dismiss()
                end
            end,
            c = cmp.mapping.close(),
        },
        ['<CR>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            elseif copilot_status and copilot_suggestion.is_visible() then
                copilot_suggestion.accept()
            else
                fallback()
            end
        end),
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif is_line_empty() then
                fallback()
            else
                cmp.complete()
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

    local cmp_sources = cmp.config.sources({
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'rg',      keyword_length = 3 },
        { name = 'luasnip', keyword_length = 2 },
    })

    return {
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
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
        preselect = cmp.PreselectMode.Item,
        completion = {
            autocomplete = false,
            completeopt  = 'menuone',
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
            { name = 'rg' }
        }
    })

    cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        completion = {
            completeopt = 'menuone,noselect',
        },
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
