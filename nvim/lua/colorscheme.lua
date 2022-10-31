local M = {}
-- vim.g.plastic_nvim_transparent_bg = true
-- vim.cmd('colorscheme plastic-nvim')

vim.opt.background = 'dark'

M.colorset = {
    white       = '#d4be98',
    gray        = '#665c54',
    black       = '#21252B',
    red         = '#ea6962',
    green       = '#a9b665',
    blue        = '#7daea3',
    yellow      = '#d8a657',
    orange      = '#e78a4e',
    purple      = '#af5fff',
    magenta     = '#d3869b',
    teal        = '#5bc8af',
    cyan        = '#89b482',
    bg          = '#181a1f',
    transparent = 'NONE',
}

M.colorset.bracket = {
    "#ffd700",
    "#da70d6",
    "#87cefa"
}

M.colorset.todocomments = {
    error = { "#D74E42" },
    warn = { "#E9D16C" },
    hint = { "#98C379" },
    perf = { "#1085FF" },
    info = { "#61AFEF" },
    todo = { "#B57EDC" },
    hack = { "#D19A66" },
}

M.colorset.modes = {
    n = M.colorset.cyan,
    i = M.colorset.green,
    v = M.colorset.magenta,
    V = M.colorset.magenta,
    r = M.colorset.yellow,
    R = M.colorset.yellow,
    c = M.colorset.red,
}

M.colorset.cmp = {
    PmenuSel = { bg = "#282C34", fg = "NONE" },
    Pmenu = { fg = "#C5CDD9", bg = "#22252A" },

    CmpItemAbbrDeprecated = { fg = "#7E8294", bg = "NONE", strikethrough = true },
    CmpItemAbbrMatch = { fg = "#82AAFF", bg = "NONE", bold = true },
    CmpItemAbbrMatchFuzzy = { fg = "#82AAFF", bg = "NONE", bold = true },
    CmpItemMenu = { fg = "#C792EA", bg = "NONE", italic = true },

    CmpItemKindField = { fg = "#EED8DA", bg = "#B5585F" },
    CmpItemKindProperty = { fg = "#EED8DA", bg = "#B5585F" },
    CmpItemKindEvent = { fg = "#EED8DA", bg = "#B5585F" },

    CmpItemKindText = { fg = "#C3E88D", bg = "#9FBD73" },
    CmpItemKindEnum = { fg = "#C3E88D", bg = "#9FBD73" },
    CmpItemKindKeyword = { fg = "#C3E88D", bg = "#9FBD73" },

    CmpItemKindConstant = { fg = "#FFE082", bg = "#D4BB6C" },
    CmpItemKindConstructor = { fg = "#FFE082", bg = "#D4BB6C" },
    CmpItemKindReference = { fg = "#FFE082", bg = "#D4BB6C" },

    CmpItemKindFunction = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindStruct = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindClass = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindModule = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindOperator = { fg = "#EADFF0", bg = "#A377BF" },

    CmpItemKindVariable = { fg = "#C5CDD9", bg = "#7E8294" },
    CmpItemKindFile = { fg = "#C5CDD9", bg = "#7E8294" },

    CmpItemKindUnit = { fg = "#F5EBD9", bg = "#D4A959" },
    CmpItemKindSnippet = { fg = "#F5EBD9", bg = "#D4A959" },
    CmpItemKindFolder = { fg = "#F5EBD9", bg = "#D4A959" },

    CmpItemKindMethod = { fg = "#DDE5F5", bg = "#6C8ED4" },
    CmpItemKindValue = { fg = "#DDE5F5", bg = "#6C8ED4" },
    CmpItemKindEnumMember = { fg = "#DDE5F5", bg = "#6C8ED4" },

    CmpItemKindInterface = { fg = "#D8EEEB", bg = "#58B5A8" },
    CmpItemKindColor = { fg = "#D8EEEB", bg = "#58B5A8" },
    CmpItemKindTypeParameter = { fg = "#D8EEEB", bg = "#58B5A8" },
}

-- INFO: kanagawa theme config
local kanagawa_status, kanagawa = pcall(require, 'kanagawa')
if kanagawa_status then

    local navic_colors = require('kanagawa.colors').setup()
    M.navic_highlight = {
        NavicIconsFile = { fg = navic_colors.springViolet2 },
        NavicIconsModule = { fg = navic_colors.boatYellow2 },
        NavicIconsNamespace = { fg = navic_colors.springViolet2 },
        NavicIconsPackage = { fg = navic_colors.springViolet1 },
        NavicIconsClass = { fg = navic_colors.surimiOrange },
        NavicIconsMethod = { fg = navic_colors.crystalBlue },
        NavicIconsProperty = { fg = navic_colors.waveAqua2 },
        NavicIconsField = { fg = navic_colors.waveAqua1 },
        NavicIconsConstructor = { fg = navic_colors.surimiOrange },
        NavicIconsEnum = { fg = navic_colors.boatYellow2 },
        NavicIconsInterface = { fg = navic_colors.carpYellow },
        NavicIconsFunction = { fg = navic_colors.crystalBlue },
        NavicIconsVariable = { fg = navic_colors.oniViolet },
        NavicIconsConstant = { fg = navic_colors.oniViolet },
        NavicIconsString = { fg = navic_colors.springGreen },
        NavicIconsNumber = { fg = navic_colors.sakuraPink },
        NavicIconsBoolean = { fg = navic_colors.surimiOrange },
        NavicIconsArray = { fg = navic_colors.waveAqua2 },
        NavicIconsObject = { fg = navic_colors.surimiOrange },
        NavicIconsKey = { fg = navic_colors.oniViolet },
        NavicIconsNull = { fg = navic_colors.carpYellow },
        NavicIconsEnumMember = { fg = navic_colors.carpYellow },
        NavicIconsStruct = { fg = navic_colors.surimiOrange },
        NavicIconsEvent = { fg = navic_colors.surimiOrange },
        NavicIconsOperator = { fg = navic_colors.springViolet2 },
        NavicIconsTypeParameter = { fg = navic_colors.springBlue },
        NavicText = { fg = M.colorset.white },
        NavicSeparator = { fg = M.colorset.orange },
    }

    kanagawa.setup({
        transparent = false,
        globalStatus = true,
        terminalColors = false,
        colors = {
            fg_border = M.colorset.white,
            bg = M.colorset.bg,
        },
    })
    vim.cmd.colorscheme 'kanagawa'
end

-- override signcolumn fg to be transparent
vim.api.nvim_set_hl(0, 'SignColumn', { fg = M.colorset.transparent, bg = M.colorset.transparent })
vim.api.nvim_set_hl(0, 'Pmenu', { fg = M.colorset.transparent, bg = M.colorset.black })

-- override floatborder bg
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = M.colorset.transparent })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = M.colorset.transparent })

-- override MoreMsg highlight
vim.api.nvim_set_hl(0, 'MoreMsg', { fg = M.colorset.blue, bg = M.colorset.transparent })

-- override CMP highlight groups
for group, colors in pairs(M.colorset.cmp) do
    vim.api.nvim_set_hl(0, group, colors)
end

return M
