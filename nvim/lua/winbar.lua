local M = {}

local winbar_filetype_exclude = {
    "help",
    "packer",
    "toggleterm",
    "TelescopePrompt",
    "TelescopeResults"
}

-- INFO: winbar colorscheme
-- vim.api.nvim_set_hl(0, 'WinBar', { fg = '#e4e4e4', bg = 'NONE', bold = true })
vim.api.nvim_set_hl(0, 'WinBarPath', { fg = '#e4e4e4', bg = '#6100e0' })
vim.api.nvim_set_hl(0, 'WinBarModified', { fg = '#ff3838' })
vim.api.nvim_set_hl(0, 'WinBarNC', { fg = '#a8a8a8', bg = 'NONE' })

function M.statusline()
    if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
        return ''
    end

    local modified = vim.api.nvim_eval_statusline('%M', {}).str == '+' and ' ' or ''

    return '%=  %#WinBarPath# %*%#WinBarModified#' .. modified .. '%* %f '
end

return M
