local M = {
    'MomePP/marks.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
}

M.opts = {
    -- whether to map keybinds or not. default true
    default_mappings = false,
    -- which builtin marks to show. default {}
    builtin_marks = {},
    -- whether movements cycle back to the beginning/end of buffer. default true
    cyclic = true,
    -- whether the shada file is updated after modifying uppercase marks. default false
    force_write_shada = false,
    -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
    -- marks, and bookmarks.
    -- can be ither a table with all/none of the keys, or a single number, in which case
    -- the priority applies to all marks.
    -- default 10.
    sign_priority = 15,
    -- disables mark tracking for specific filetypes. default {}
    excluded_filetypes = {
        'toggleterm',
        'lspinfo',
        'terminal',
        'help',
    },
    -- extra options modified by `MomePP/marks.nvim`
    marks_sign = '󱙝',
}


M.config = function(_, opts)
    require('marks').setup(opts)

    -- NOTE: refresh marks after written buffer
    vim.api.nvim_create_autocmd('BufWritePost', {
        group = vim.api.nvim_create_augroup('marks_refresh', { clear = true }),
        callback = function() require('marks').refresh(true) end
    })
end

M.keys = function()
    local marks_keymap = require('config.keymaps').marks

    return {
        { marks_keymap.toggle, function() require('marks').toggle() end },
        { marks_keymap.next,   function() require('marks').next() end },
        { marks_keymap.prev,   function() require('marks').prev() end },
        { marks_keymap.clear,  function() require('marks').delete_buf() end },

        -- NOTE: use quickfix to show all marks
        {
            marks_keymap.list,
            function()
                local gen_items = function(marks_tbl)
                    local items = {}
                    for _, mark in ipairs(marks_tbl) do
                        local path = mark.path
                        local buf = mark.bufnr
                        local line = mark.line
                        local label = mark.mark
                        items[#items + 1] = {
                            text = table.concat({ label, path, line }, " "),
                            label = label,
                            buf = buf,
                            file = path,
                            pos = { mark.lnum, mark.col },
                        }
                    end
                    table.sort(items, function(a, b)
                        if a.file == b.file then
                            return a.label < b.label
                        else
                            return a.file < b.file
                        end
                    end)
                    return items
                end

                require('snacks').picker.pick({
                    source = 'marks.nvim',
                    format = 'file',
                    items = gen_items(require('marks').mark_state:get_all_list() or {}),
                })
            end
        },
    }
end

return M
