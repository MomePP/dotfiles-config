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

    local function leap_all_windows()
        require('leap').leap {
            target_windows = vim.tbl_filter(
                function(win)
                    return vim.api.nvim_win_get_config(win).focusable
                end,
                vim.api.nvim_tabpage_list_wins(0)
            )
        }
    end

    return {
        { flit_keymap.forward },
        { flit_keymap.backward },
        { flit_keymap.till },
        { flit_keymap.backtill },
        { flit_keymap.leap, leap_all_windows },
    }
end

return M
