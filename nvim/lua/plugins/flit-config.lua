local M = {
    'ggandor/flit.nvim',

    dependencies = {
        'ggandor/leap.nvim',
    },
}

M.opts = {
    labeled_modes = 'nv',
    opts = {
        highlight_unlabeled_phase_one_targets = true,
    },
}

M.keys = function()
    local flit_keymap = require('config.keymaps').flit

    return {
        { flit_keymap.forward },
        { flit_keymap.backward },
        { flit_keymap.till },
        { flit_keymap.backtill },
    }
end

return M
