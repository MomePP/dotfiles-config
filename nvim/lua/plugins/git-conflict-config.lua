local M = {
    'akinsho/git-conflict.nvim',
    event = 'BufReadPre'
}

M.opts = {
    default_mappings = true,
    default_commands = true,
    disable_diagnostics = true,
    highlights = {
        incoming = 'DiffText',
        current = 'DiffAdd',
    }
}

M.keys = function()
    local git_conflict = require('git-conflict')
    local gitconflict_keymap = require('config.keymaps').gitconflict

    return {
        {
            gitconflict_keymap.toggle_qflist,
            function()
                git_conflict.conflicts_to_qf_items(function(items)
                    if #items > 0 then
                        vim.fn.setqflist(items, 'r')
                        vim.cmd 'Telescope quickfix'
                    else
                        vim.notify('There is no conflict -  ', vim.log.levels.WARN)
                    end
                end)
            end
        },
    }
end

return M
