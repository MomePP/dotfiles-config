local status_ok, ufo = pcall(require, 'ufo')
if not status_ok then return end

ufo.setup({
    close_fold_kinds = { 'imports', 'comment' },
    preview = {
        win_config = {
            border = { '', '─', '', '', '', '─', '', '' },
            -- border = 'rounded',
            winhighlight = 'Normal:Normal',
            winblend = 0
        },
        mappings = {
            scrollU = '<C-u>',
            scrollD = '<C-d>'
        }
    },
    provider_selector = function(_, _, _)
        return { 'treesitter', 'indent' }
    end,
    fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ('  %d '):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
            local chunkText = chunk[1]
            local chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if targetWidth > curWidth + chunkWidth then
                table.insert(newVirtText, chunk)
            else
                chunkText = truncate(chunkText, targetWidth - curWidth)
                local hlGroup = chunk[2]
                table.insert(newVirtText, { chunkText, hlGroup })
                chunkWidth = vim.fn.strdisplaywidth(chunkText)
                if curWidth + chunkWidth < targetWidth then
                    suffix = suffix .. (' '):rep(targetWidth - curWidth - chunkWidth)
                end
                break
            end
            curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, 'MoreMsg' })
        return newVirtText
    end,
})

local ufo_keymaps = require('keymappings').ufo

vim.keymap.set('n', ufo_keymaps.open_all, ufo.openAllFolds, ufo_keymaps.opts)
vim.keymap.set('n', ufo_keymaps.open_except, ufo.openFoldsExceptKinds, ufo_keymaps.opts)
vim.keymap.set('n', ufo_keymaps.close_all, ufo.closeAllFolds, ufo_keymaps.opts)
vim.keymap.set('n', ufo_keymaps.close_with, ufo.closeFoldsWith, ufo_keymaps.opts) -- closeAllFolds == closeFoldsWith(0)
