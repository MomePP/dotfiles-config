local M = {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy'
}

M.opts = {
    signcolumn = true,
    preview_config = {
        border = require('config').defaults.float_border,
        row    = 1,
        col    = -1,
    },
    on_attach = function(bufnr)
        local gitsigns_keymap = require('config.keymaps').gitsigns
        local gitsigns_actions = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        map('n', gitsigns_keymap.next_hunk,
            function()
                if vim.wo.diff then return gitsigns_keymap.next_hunk end
                vim.schedule(function() gitsigns_actions.next_hunk() end)
                return '<Ignore>'
            end, { expr = true })

        map('n', gitsigns_keymap.prev_hunk,
            function()
                if vim.wo.diff then return gitsigns_keymap.prev_hunk end
                vim.schedule(function() gitsigns_actions.prev_hunk() end)
                return '<Ignore>'
            end, { expr = true })

        map('n', gitsigns_keymap.stage_hunk, gitsigns_actions.stage_hunk)
        map('v', gitsigns_keymap.stage_hunk, function() gitsigns_actions.stage_hunk { vim.fn.line('.'), vim.fn.line('v')} end)

        map('n', gitsigns_keymap.reset_hunk, gitsigns_actions.reset_hunk)
        map('v', gitsigns_keymap.reset_hunk, function() gitsigns_actions.reset_hunk { vim.fn.line('.'), vim.fn.line('v')} end)

        map('n', gitsigns_keymap.preview_hunk, gitsigns_actions.preview_hunk_inline)

        map('n', gitsigns_keymap.blame_line, function() gitsigns_actions.blame_line { full = true } end)
        map('n', gitsigns_keymap.toggle_blame, gitsigns_actions.toggle_current_line_blame)

        map('n', gitsigns_keymap.diff_this, gitsigns_actions.diffthis)
    end
}

return M
