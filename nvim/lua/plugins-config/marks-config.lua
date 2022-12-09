local status_ok, marks = pcall(require, 'marks')
if not status_ok then return end

marks.setup {
    -- whether to map keybinds or not. default true
    default_mappings = false,
    -- which builtin marks to show. default {}
    builtin_marks = {},
    -- whether movements cycle back to the beginning/end of buffer. default true
    cyclic = true,
    -- whether the shada file is updated after modifying uppercase marks. default false
    force_write_shada = true,
    -- how often (in ms) to redraw signs/recompute mark positions.
    -- higher values will have better performance but may cause visual lag,
    -- while lower values may cause performance penalties. default 150.
    refresh_interval = 250,
    -- sign priorities for each type of mark - builtin marks, uppercase marks, lowercase
    -- marks, and bookmarks.
    -- can be ither a table with all/none of the keys, or a single number, in which case
    -- the priority applies to all marks.
    -- default 10.
    sign_priority = { lower = 10, upper = 15, builtin = 8, bookmark = 20 },
    -- disables mark tracking for specific filetypes. default {}
    excluded_filetypes = {
        'toggleterm',
        'lspinfo',
        'lsp-installer',
        'terminal',
        'packer',
        'help',
        'TelescopePrompt',
        'TelescopeResults',
    },
    -- marks.nvim allows you to configure up to 10 bookmark groups, each with its own
    -- sign/virttext. Bookmarks can be used to group together positions and quickly move
    -- across multiple buffers. default sign is '!@#$%^&*()' (from 0 to 9), and
    -- default virt_text is "".
    bookmark_0 = {
        sign = '',
        -- virt_text = '-  ',
    },
}

local colors = require('colorscheme').colorset
local marks_keymaps = require('keymappings').marks
-- local marks_group = 0
--
-- local function group_under_cursor()
--     local bufnr = vim.api.nvim_get_current_buf()
--     local pos = vim.api.nvim_win_get_cursor(0)
--
--     for group_nr, group in pairs(marks.bookmark_state.groups) do
--         if group.marks[bufnr] and group.marks[bufnr][pos[1]] then
--             return group_nr
--         end
--     end
--     return nil
-- end

-- INFO: set keymap for marks.nvim
-- vim.keymap.set('n', marks_keymaps.toggle,
--     function()
--         if group_under_cursor() ~= nil then marks.bookmark_state:delete_mark_cursor()
--         else marks.bookmark_state:place_mark(marks_group) end
--     end, marks_keymaps.opts)
-- vim.keymap.set('n', marks_keymaps.next, function() marks.bookmark_state:next(marks_group) end, marks_keymaps.opts)
-- vim.keymap.set('n', marks_keymaps.prev, function() marks.bookmark_state:prev(marks_group) end, marks_keymaps.opts)
-- vim.keymap.set('n', marks_keymaps.clear, function() marks.bookmark_state:delete_all(marks_group) end, marks_keymaps.opts)

vim.keymap.set('n', marks_keymaps.toggle, marks.toggle, marks_keymaps.opts)
vim.keymap.set('n', marks_keymaps.preview, marks.preview, marks_keymaps.opts)
vim.keymap.set('n', marks_keymaps.next, marks.next, marks_keymaps.opts)
vim.keymap.set('n', marks_keymaps.prev, marks.prev, marks_keymaps.opts)
vim.keymap.set('n', marks_keymaps.clear, marks.delete_buf, marks_keymaps.opts)

-- NOTE: used `trouble.nvim` quickfix to show all marks
vim.keymap.set('n', marks_keymaps.list, function()
    marks.mark_state:all_to_list('quickfixlist')
    if vim.tbl_isempty(vim.fn.getqflist()) then
        vim.notify('There is no bookmarks -  ', vim.log.levels.WARN)
        return
    end
    vim.cmd 'TroubleToggle quickfix'
end, marks_keymaps.opts)

-- INFO: set marks sign highlight
vim.api.nvim_set_hl(0, 'MarkSignHL', { fg = colors.bright_blue })
-- vim.api.nvim_set_hl(0, 'MarkVirtTextHL', { fg = colors.bright_blue, bg = colors.transparent, nocombine = true })
