local M = {}
-- vim.g.plastic_nvim_transparent_bg = true
-- vim.cmd('colorscheme plastic-nvim')

vim.opt.background = 'dark'

M.colorset = {
    white        = '#d4be98',
    gray         = '#928374',
    black        = '#665c54',
    red          = '#ea6962',
    green        = '#a9b665',
    blue         = '#7daea3',
    yellow       = '#d8a657',
    orange       = '#e78a4e',
    purple       = '#af5fff',
    magenta      = '#d3869b',
    teal         = '#5bc8af',
    cyan         = '#89b482',
    bg           = '#181a1f',
    transparent  = 'NONE',
    bracket      = {
        "#ffd700",
        "#da70d6",
        "#87cefa"
    },
    todocomments = {
        error = { "#D74E42" },
        warn = { "#E9D16C" },
        hint = { "#98C379" },
        perf = { "#1085FF" },
        info = { "#61AFEF" },
        todo = { "#B57EDC" },
        hack = { "#D19A66" },
    },
}

-- local colorset = {
--     purple = '#6100e0',
--     red = '#ff3838',
--     white = '#e4e4e4',
--     gray = '#727169',
--     orange = '#ff7800',
--     black = '#303030',
--     transparent = 'NONE',
-- }

-- INFO: kanagawa theme config
require('kanagawa').setup({
    transparent = true, -- do not set background color
    globalStatus = true,
    terminalColors = false,
    colors = {
        fg_border = M.colorset.white,
        bg = M.colorset.bg,
    },
})
vim.cmd.colorscheme 'kanagawa'

-- INFO: adwaita theme config
-- vim.g.adwaita_darker = true
-- vim.cmd.colorscheme('adwaita')

-- override signcolumn fg to be transparent
vim.api.nvim_set_hl(0, 'SignColumn', { fg = M.colorset.transparent, bg = M.colorset.transparent })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = M.colorset.transparent, bg = M.colorset.transparent })

-- override floatborder bg
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = M.colorset.transparent })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = M.colorset.transparent })

return M
