local ufo_keymap = require('config.keymaps').ufo

local M = {
    'kevinhwang91/nvim-ufo',
    event = 'BufReadPost',

    dependencies = {
        'nvim-treesitter',
        'kevinhwang91/promise-async'
    }
}

M.opts = {
    close_fold_kinds = { 'imports', 'comment' },
    preview = {
        win_config = {
            border = { '', '─', '', '', '', '─', '', '' },
            winhighlight = 'Normal:Normal',
            winblend = 0
        },
        mappings = {
            scrollU = ufo_keymap.scroll_up,
            scrollD = ufo_keymap.scroll_down
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
}

M.keys = function()

    return {
        { ufo_keymap.open_all, function() require('ufo').openAllFolds() end },
        { ufo_keymap.open_except, function() require('ufo').openFoldsExceptKinds() end },
        { ufo_keymap.close_all, function() require('ufo').closeAllFolds() end },
        { ufo_keymap.close_with, function() require('ufo').closeFoldsWith() end },
    }
end

return M
