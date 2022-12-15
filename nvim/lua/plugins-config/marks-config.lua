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
        'lsp-installer',
        'terminal',
        'packer',
        'help',
        'TelescopePrompt',
        'TelescopeResults',
    },
    -- extra options modified by `MomePP/marks.nvim`
    marks_sign = '',
}

local colors = require('colorscheme').colorset
local marks_keymaps = require('keymappings').marks

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
