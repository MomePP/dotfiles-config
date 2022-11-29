local status_ok, git_conflict = pcall(require, 'git-conflict')
if not status_ok then return end

git_conflict.setup({
    default_mappings = true,
    default_commands = true,
    disable_diagnostics = true,
    highlights = {
        incoming = 'DiffText',
        current = 'DiffAdd',
    }
})

local gitconflict_keymap = require('keymappings').gitconflict

vim.keymap.set('n', gitconflict_keymap.toggle_qflist, function()
    git_conflict.conflicts_to_qf_items(function(items)
        if #items > 0 then
            vim.fn.setqflist(items, 'r')
            vim.cmd 'TroubleToggle quickfix'
        else
            vim.notify('There is no conflict -  ', vim.log.levels.WARN)
        end
    end)
end, gitconflict_keymap.opts)
