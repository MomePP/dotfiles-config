local M = {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    dependencies = {
        -- NOTE: cmp sources
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',

        -- NOTE: snippet plugins
        {
            'garymjr/nvim-snippets',
            opts = {
                friendly_snippets = true,
                search_paths = {
                    vim.fn.stdpath('config') .. '/snippets',
                    vim.fn.stdpath('data') .. '/lazy/friendly-snippets/snippets/frameworks',
                },
                extended_filetypes = {
                    vue = { 'html', 'javascript' },
                },
            },
            dependencies = { 'rafamadriz/friendly-snippets' },
        },

        -- NOTE: autopairs plugin
        {
            'windwp/nvim-autopairs',
            opts = { check_ts = true, fast_wrap = { map = '<C-e>' } },
        },

        -- NOTE: github copilot if available
        'copilot.lua',

        -- NOTE: misc. plugins
        'onsails/lspkind.nvim',
    },
}

M.opts = function()
    local cmp = require('cmp')
    local default_border = require('config').defaults.float_border

    local copilot_status, copilot_suggestion = pcall(require, 'copilot.suggestion')

    local lspkind_format = require('lspkind').cmp_format({
        mode = 'symbol_text',
        maxwidth = 50,
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
            elseif vim.snippet.jumpable(1) then
                vim.schedule(function() vim.snippet.jump(1) end)
            elseif has_word_before() then
                cmp.complete()
            elseif copilot_status and copilot_suggestion.is_visible() then
                copilot_suggestion.next()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif vim.snippet.jumpable(-1) then
                vim.schedule(function() vim.snippet.jump(-1) end)
            elseif copilot_status and copilot_suggestion.is_visible() then
                copilot_suggestion.prev()
            else
                fallback()
            end
        end, { 'i', 's' }),
    }

    local cmp_sorting = {
        priority_weight = 2,
        comparators = {
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
            { name = 'path' },
            { name = 'snippets', keyword_length = 2 },
            { name = 'nvim_lsp' },
            { name = 'buffer' },
        }
    )

    return {
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
                winhighlight = 'Normal:Pmenu,FloatBorder:Pmenu'
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
            { name = 'buffer' },
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

    -- NOTE: copilot hide suggestion when cmp opened
    cmp.event:on('menu_opened', function()
        vim.b.copilot_suggestion_hidden = true
    end)

    cmp.event:on('menu_closed', function()
        vim.b.copilot_suggestion_hidden = false
    end)

    -- NOTE: autopairs mapping on <CR>
    cmp.event:on('confirm_done', require('nvim-autopairs.completion.cmp').on_confirm_done())
end

return M
