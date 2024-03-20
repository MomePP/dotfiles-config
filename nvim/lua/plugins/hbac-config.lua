local hbac_keymap = require('config.keymaps').hbac

local M = {
    'axkirillov/hbac.nvim',
}

M.opts = function()
    local actions = require('hbac.telescope.actions')

    return {
        close_command = function(bufnr)
            -- INFO: lazy loads `mini.bufremove` for handles buffer deletion
            require('lazy').load({ plugins = { 'mini.bufremove' } })
            local force = vim.api.nvim_get_option_value('buftype', { buf = bufnr }) == 'terminal'
            pcall(require('mini.bufremove').delete, bufnr, force)
        end,
        threshold = 20,
        telescope = {
            sort_mru = true,
            sort_lastused = false,
            use_default_mappings = false,
            mappings = {
                i = {
                    [hbac_keymap.action_delete.i] = actions.delete_buffer,
                    [hbac_keymap.action_pin_all.i] = actions.pin_all,
                    [hbac_keymap.action_unpin_all.i] = actions.unpin_all,
                    [hbac_keymap.action_toggle_pin.i] = actions.toggle_pin,
                    [hbac_keymap.action_close_unpinned.i] = actions.close_unpinned,
                },
                n = {
                    [hbac_keymap.action_delete.n] = actions.delete_buffer,
                    [hbac_keymap.action_pin_all.n] = actions.pin_all,
                    [hbac_keymap.action_unpin_all.n] = actions.unpin_all,
                    [hbac_keymap.action_toggle_pin.n] = actions.toggle_pin,
                    [hbac_keymap.action_close_unpinned.n] = actions.close_unpinned,
                }
            }
        }
    }
end

return M
