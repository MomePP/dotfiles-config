local M = {}

local winbar_filetype_exclude = {
    "help",
    "packer",
    "toggleterm",
    "TelescopePrompt",
    "TelescopeResults"
}

local colors = {
    purple = '#6100e0',
    red = '#ff3838',
    white = '#e4e4e4',
    gray = '#989898',
    transparent = 'NONE',
}

-- INFO: winbar colorscheme
-- New winbar colorscheme
vim.api.nvim_set_hl(0, 'WinBarPath', { fg = colors.white, bg = colors.purple })
vim.api.nvim_set_hl(0, 'WinBarModified', { fg = colors.red, bg = colors.transparent })
vim.api.nvim_set_hl(0, 'WinBarNC', { fg = colors.gray, bg = colors.transparent, bold = false })

-- Old incline colorscheme
-- vim.api.nvim_set_hl(0, 'WinBar', { fg = colors.white, bg = colors.purple, bold = true })
-- vim.api.nvim_set_hl(0, 'WinBarSpace', { fg = colors.white, bg = colors.transparent })
-- vim.api.nvim_set_hl(0, 'WinBarModified', { fg = colors.red, bg = colors.purple })
-- vim.api.nvim_set_hl(0, 'WinBarNC', { fg = colors.gray, bg = colors.transparent, bold = false })

function M.statusline()
    if vim.tbl_contains(winbar_filetype_exclude, vim.bo.filetype) then
        return ''
    end

    local modified = vim.api.nvim_eval_statusline('%M', {}).str == '+' and ' ' or ''

    -- New winbar colorscheme
    return '%=%#WinBarPath# %*%#WinBarModified#' .. modified .. '%* %f '

    -- Old incline colorscheme ** the active one is purple bg
    -- return '%#WinBarSpace#%=%*%#WinBarModified#' .. modified .. '%* %f '
end

return M
