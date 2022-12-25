local M = {
    'akinsho/git-conflict.nvim',
    event = 'BufReadPre'
}

M.config = function()
    local git_conflict = require('git-conflict')
    git_conflict.setup({
        default_mappings = true,
        default_commands = true,
        disable_diagnostics = true,
        highlights = {
            incoming = 'DiffText',
            current = 'DiffAdd',
        }
    })

    local gitconflict_keymap = require('keymaps').gitconflict
    vim.keymap.set('n', gitconflict_keymap.toggle_qflist, function()
        git_conflict.conflicts_to_qf_items(function(items)
            if #items > 0 then
                vim.fn.setqflist(items, 'r')
                vim.cmd 'Telescope quickfix'
            else
                vim.notify('There is no conflict -  ', vim.log.levels.WARN)
            end
        end)
    end, gitconflict_keymap.opts)
end

return M
