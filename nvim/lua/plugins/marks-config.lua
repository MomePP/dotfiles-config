local M = {
    -- 'chentoast/marks.nvim',
    'MomePP/marks.nvim',
    event = { 'BufReadPost', 'BufNewFile' }
}

M.opts = {
    -- whether to map keybinds or not. default true
    default_mappings = false,
    -- which builtin marks to show. default {}
    builtin_marks = {},
    -- whether movements cycle back to the beginning/end of buffer. default true
    cyclic = true,
    -- whether the shada file is updated after modifying uppercase marks. default false
    force_write_shada = true,
    -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
    -- marks, and bookmarks.
    -- can be ither a table with all/none of the keys, or a single number, in which case
    -- the priority applies to all marks.
    -- default 10.
    sign_priority = { lower = 10, upper = 15, builtin = 8 },
    -- disables mark tracking for specific filetypes. default {}
    excluded_filetypes = {
        'toggleterm',
        'lspinfo',
        'terminal',
        'help',
        'TelescopePrompt',
        'TelescopeResults',
    },
    -- extra options modified by `MomePP/marks.nvim`
    marks_sign = '',
}

M.keys = function()
    local marks_keymap = require('config.keymaps').marks

    return {
        { marks_keymap.toggle, function() require('marks').toggle() end },
        { marks_keymap.next,   function() require('marks').next() end },
        { marks_keymap.prev,   function() require('marks').prev() end },
        { marks_keymap.clear,  function() require('marks').delete_buf() end },

        -- NOTE: preview marks in current buffer
        {
            marks_keymap.preview,
            function()
                local mark = require('marks').mark_state:get_nearest_next_mark()
                if not mark then
                    vim.notify('No marks to preview -  ', vim.log.levels.WARN)
                    return
                end

                local pos = vim.fn.getpos("'" .. mark)
                if pos[2] == 0 then
                    return
                end

                local width = vim.api.nvim_win_get_width(0)
                local height = vim.api.nvim_win_get_height(0)
                vim.api.nvim_open_win(pos[1], true, {
                    relative = 'win',
                    win = 0,
                    width = math.floor(width / 2),
                    height = math.floor(height / 2),
                    col = math.floor(width / 4),
                    row = math.floor(height / 8),
                    border = require('config').defaults.float_border,
                    -- title = ' Marks previewer '
                })
                vim.cmd('normal! `' .. mark)
                vim.cmd('normal! zz')
            end
        },

        -- NOTE: use quickfix to show all marks
        {
            marks_keymap.list,
            function()
                require('marks').mark_state:all_to_list('quickfixlist')
                if vim.tbl_isempty(vim.fn.getqflist()) then
                    vim.notify('There is no marks -  ', vim.log.levels.WARN)
                    return
                end
                vim.cmd 'TroubleToggle quickfix'
            end
        },
    }
end

return M
