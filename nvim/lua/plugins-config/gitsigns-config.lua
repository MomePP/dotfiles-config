local status_ok, gitsigns = pcall(require, 'gitsigns')
if not status_ok then return end

gitsigns.setup {
    -- opts in `preview_config` passed to `nvim_open_win`
    preview_config = {
        border = 'none',
        style = 'minimal',
        relative = 'cursor',
        row = 1,
        col = 0,
        focusable = false,
    },
}

local gitsigns_keymap = require('keymappings').gitsigns
local gitsigns_actions = require('gitsigns.actions')

vim.keymap.set('n', gitsigns_keymap.next_hunk,
    function()
        if vim.wo.diff then return gitsigns_keymap.next_hunk end
        vim.schedule(function() gitsigns_actions.next_hunk() end)
        return '<Ignore>'
    end, gitsigns_keymap.opts.expr)

vim.keymap.set('n', gitsigns_keymap.prev_hunk,
    function()
        if vim.wo.diff then return gitsigns_keymap.prev_hunk end
        vim.schedule(function() gitsigns_actions.prev_hunk() end)
        return '<Ignore>'
    end, gitsigns_keymap.opts.expr)

vim.keymap.set('n', gitsigns_keymap.blame_line,
    function()
        gitsigns_actions.blame_line { full = true }
    end, gitsigns_keymap.opts.silent)

vim.keymap.set({ 'n', 'v' }, gitsigns_keymap.reset_hunk, gitsigns_actions.reset_hunk, gitsigns_keymap.opts.silent)
vim.keymap.set('n', gitsigns_keymap.preview_hunk, gitsigns_actions.preview_hunk_inline, gitsigns_keymap.opts.silent)
vim.keymap.set('n', gitsigns_keymap.toggle_blame, gitsigns_actions.toggle_current_line_blame, gitsigns_keymap.opts.silent)
