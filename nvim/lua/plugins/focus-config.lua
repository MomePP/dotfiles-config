local M = {
    'nvim-focus/focus.nvim',
    event = 'VeryLazy'
}

M.init = function()
    local ignore_filetypes = { 'telescopeprompt', 'toggleterm', 'noice' }
    local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

    local augroup = vim.api.nvim_create_augroup('FocusDisable', { clear = true })
    vim.api.nvim_create_autocmd('WinEnter', {
        group = augroup,
        callback = function(_)
            if vim.tbl_contains(ignore_buftypes, vim.bo.buftype) then
                vim.w.focus_disable = true
            else
                vim.w.focus_disable = false
            end
        end,
        desc = 'Disable focus autoresize for BufType',
    })
    vim.api.nvim_create_autocmd('FileType', {
        group = augroup,
        callback = function(_)
            if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
                vim.w.focus_disable = true
            else
                vim.w.focus_disable = false
            end
        end,
        desc = 'Disable focus autoresize for FileType',
    })
end

M.opts = {
    ui = { signcolumn = false }
}

M.keys = function()
    local focus_keymaps = require('config.keymaps').focus

    return {
        { focus_keymaps.toggle_enable, '<Cmd>FocusToggle<CR>' },
        { focus_keymaps.toggle_size,   '<Cmd>FocusMaxOrEqual<CR>' },
        { focus_keymaps.split_cycle,   '<Cmd>FocusSplitCycle<CR>' },
        { focus_keymaps.split_left,    '<Cmd>FocusSplitLeft<CR>' },
        { focus_keymaps.split_right,   '<Cmd>FocusSplitRight<CR>' },
        { focus_keymaps.split_up,      '<Cmd>FocusSplitUp<CR>' },
        { focus_keymaps.split_down,    '<Cmd>FocusSplitDown<CR>' },
    }
end

return M
