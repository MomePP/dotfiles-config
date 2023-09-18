local M = {
    'folke/flash.nvim',
}

M.opts = {
    search = {
        mode = 'fuzzy',
        incremental = true,
    },
    modes = {
        char = {
            jump_labels = true
        }
    }
}

M.keys = function()
    local flash_keymap = require('config.keymaps').flash

    return {
        { flash_keymap.search },
        { flash_keymap.backsearch },
        { flash_keymap.forward },
        { flash_keymap.backward },
        { flash_keymap.till },
        { flash_keymap.backtill },
        {
            flash_keymap.flash,
            mode = { 'n', 'o', 'x' },
            function() require('flash').jump() end,
            desc = 'Flash'
        },
        {
            flash_keymap.flash_treesitter,
            mode = { 'n', 'o', 'x' },
            function() require('flash').treesitter() end,
            desc = 'Flash Treesitter'
        },
    }
end

return M
