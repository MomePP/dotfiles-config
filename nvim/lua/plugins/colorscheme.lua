local M = {
    'rebelot/kanagawa.nvim',
    lazy = false,
    priority = 1000
}

vim.opt.background = 'dark'

M.colorset = {
    white       = '#d4be98',
    gray        = '#928374',
    black       = '#21252B',
    red         = '#ea6962',
    green       = '#a9b665',
    blue        = '#7daea3',
    bright_blue = '#1085FF',
    yellow      = '#d8a657',
    orange      = '#e78a4e',
    purple      = '#af5fff',
    magenta     = '#d3869b',
    teal        = '#5bc8af',
    cyan        = '#89b482',
    bg          = '#1d2021',
    bg0         = '#282828',
    bg1         = '#3c3836',
    bg2         = '#504945',
    bg3         = '#665c54',
    transparent = 'NONE',
}

M.colorset.bracket = {
    '#ffd700',
    '#da70d6',
    '#87cefa'
}

M.colorset.todocomments = {
    error = '#D74E42',
    warn  = '#E9D16C',
    hint  = '#98C379',
    perf  = '#1085FF',
    info  = '#61AFEF',
    todo  = '#B57EDC',
    hack  = '#D19A66',
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

M.config = function()

    -- INFO: kanagawa theme config
    local kanagawa_status, kanagawa = pcall(require, 'kanagawa')
    if kanagawa_status then

        local kanagawa_colors = require('kanagawa.colors').setup()
        local highlight_overrides = {}

        local function addHighlightConfig(rhs)
            highlight_overrides = vim.tbl_deep_extend('force', highlight_overrides, rhs)
        end

        local override_highlight = {
            WinSeparator = { fg = M.colorset.bg1, bg = M.colorset.transparent },
            SignColumn = { fg = M.colorset.transparent, bg = M.colorset.transparent },
            NormalFloat = { bg = M.colorset.bg0 },
            FloatBorder = { bg = M.colorset.bg0 },
            MoreMsg = { fg = M.colorset.blue, bg = M.colorset.transparent },
        }

        local navic_highlight = {
            NavicIconsFile = { fg = kanagawa_colors.springViolet2 },
            NavicIconsModule = { fg = kanagawa_colors.boatYellow2 },
            NavicIconsNamespace = { fg = kanagawa_colors.springViolet2 },
            NavicIconsPackage = { fg = kanagawa_colors.springViolet1 },
            NavicIconsClass = { fg = kanagawa_colors.surimiOrange },
            NavicIconsMethod = { fg = kanagawa_colors.crystalBlue },
            NavicIconsProperty = { fg = kanagawa_colors.waveAqua2 },
            NavicIconsField = { fg = kanagawa_colors.waveAqua1 },
            NavicIconsConstructor = { fg = kanagawa_colors.surimiOrange },
            NavicIconsEnum = { fg = kanagawa_colors.boatYellow2 },
            NavicIconsInterface = { fg = kanagawa_colors.carpYellow },
            NavicIconsFunction = { fg = kanagawa_colors.crystalBlue },
            NavicIconsVariable = { fg = kanagawa_colors.oniViolet },
            NavicIconsConstant = { fg = kanagawa_colors.oniViolet },
            NavicIconsString = { fg = kanagawa_colors.springGreen },
            NavicIconsNumber = { fg = kanagawa_colors.sakuraPink },
            NavicIconsBoolean = { fg = kanagawa_colors.surimiOrange },
            NavicIconsArray = { fg = kanagawa_colors.waveAqua2 },
            NavicIconsObject = { fg = kanagawa_colors.surimiOrange },
            NavicIconsKey = { fg = kanagawa_colors.oniViolet },
            NavicIconsNull = { fg = kanagawa_colors.carpYellow },
            NavicIconsEnumMember = { fg = kanagawa_colors.carpYellow },
            NavicIconsStruct = { fg = kanagawa_colors.surimiOrange },
            NavicIconsEvent = { fg = kanagawa_colors.surimiOrange },
            NavicIconsOperator = { fg = kanagawa_colors.springViolet2 },
            NavicIconsTypeParameter = { fg = kanagawa_colors.springBlue },
            NavicText = { fg = M.colorset.white },
            NavicSeparator = { fg = M.colorset.orange },
        }

        local cmp_highlight = {
            PmenuSel = { bg = '#282C34', fg = 'NONE' },
            Pmenu = { fg = '#C5CDD9', bg = '#22252A' },

            CmpItemAbbrDeprecated = { fg = '#7E8294', bg = 'NONE', strikethrough = true },
            CmpItemAbbrMatch = { fg = '#82AAFF', bg = 'NONE', bold = true },
            CmpItemAbbrMatchFuzzy = { fg = '#82AAFF', bg = 'NONE', bold = true },
            CmpItemMenu = { fg = '#C792EA', bg = 'NONE', italic = true },

            CmpItemKindField = { fg = '#EED8DA', bg = '#B5585F' },
            CmpItemKindProperty = { fg = '#EED8DA', bg = '#B5585F' },
            CmpItemKindEvent = { fg = '#EED8DA', bg = '#B5585F' },

            CmpItemKindText = { fg = '#C3E88D', bg = '#9FBD73' },
            CmpItemKindEnum = { fg = '#C3E88D', bg = '#9FBD73' },
            CmpItemKindKeyword = { fg = '#C3E88D', bg = '#9FBD73' },

            CmpItemKindConstant = { fg = '#FFE082', bg = '#D4BB6C' },
            CmpItemKindConstructor = { fg = '#FFE082', bg = '#D4BB6C' },
            CmpItemKindReference = { fg = '#FFE082', bg = '#D4BB6C' },

            CmpItemKindFunction = { fg = '#EADFF0', bg = '#A377BF' },
            CmpItemKindStruct = { fg = '#EADFF0', bg = '#A377BF' },
            CmpItemKindClass = { fg = '#EADFF0', bg = '#A377BF' },
            CmpItemKindModule = { fg = '#EADFF0', bg = '#A377BF' },
            CmpItemKindOperator = { fg = '#EADFF0', bg = '#A377BF' },

            CmpItemKindVariable = { fg = '#C5CDD9', bg = '#7E8294' },
            CmpItemKindFile = { fg = '#C5CDD9', bg = '#7E8294' },

            CmpItemKindUnit = { fg = '#F5EBD9', bg = '#D4A959' },
            CmpItemKindSnippet = { fg = '#F5EBD9', bg = '#D4A959' },
            CmpItemKindFolder = { fg = '#F5EBD9', bg = '#D4A959' },

            CmpItemKindMethod = { fg = '#DDE5F5', bg = '#6C8ED4' },
            CmpItemKindValue = { fg = '#DDE5F5', bg = '#6C8ED4' },
            CmpItemKindEnumMember = { fg = '#DDE5F5', bg = '#6C8ED4' },

            CmpItemKindInterface = { fg = '#D8EEEB', bg = '#58B5A8' },
            CmpItemKindColor = { fg = '#D8EEEB', bg = '#58B5A8' },
            CmpItemKindTypeParameter = { fg = '#D8EEEB', bg = '#58B5A8' },
        }

        local telescope_highlight = {
            TelescopeSelection = { bg = M.colorset.bg1 },
            TelescopeNormal = { bg = M.colorset.bg0 },
            TelescopePromptNormal = { bg = M.colorset.bg0 },
            TelescopeResultsBorder = { fg = M.colorset.bright_blue, bg = M.colorset.bg0 },
            TelescopePreviewBorder = { fg = M.colorset.bright_blue, bg = M.colorset.bg0 },
            TelescopePromptBorder = { fg = M.colorset.bright_blue, bg = M.colorset.bg0 },
            TelescopePromptTitle = { fg = M.colorset.bg, bg = M.colorset.bright_blue },
            TelescopeResultsTitle = { fg = M.colorset.bg, bg = M.colorset.bright_blue },
            TelescopePreviewTitle = { fg = M.colorset.bg, bg = M.colorset.bright_blue },
        }

        local leap_highlight = {
            -- greyout search area of `leap.nvim`
            LeapBackdrop = { fg = '#727169' },
            LeapLabelPrimary = { fg = 'cyan', bold = true, nocombine = true },
            LeapLabelSecondary = { fg = M.colorset.purple, bold = true, nocombine = true },
            LeapMatch = { fg = 'white', bold = true, nocombine = true },
        }

        local marks_highlight = {
            MarkSignHL = { fg = M.colorset.bright_blue },
            -- MarkVirtTextHL = { fg = M.colorset.bright_blue, bg = M.colorset.transparent, nocombine = true },
        }

        local illuminate_highlight = {
            IlluminatedWordText = { bg = M.colorset.bg1, bold = true, nocombine = true },
            IlluminatedWordRead = { link = 'IlluminatedWordText' },
            IlluminatedWordWrite = { link = 'IlluminatedWordText' },
        }

        local noice_highlight = {
            NoiceCmdlineIconCmdline = { bg = M.colorset.transparent, fg = M.colorset.red, bold = true },
            NoiceCmdlineIconSearch = { bg = M.colorset.transparent, fg = M.colorset.orange, bold = true },
            NoiceCmdlineIconFilter = { bg = M.colorset.transparent, fg = M.colorset.teal, bold = true },
            NoiceSplit = { bg = M.colorset.bg },
        }

        local indentscope_highlight = {
            MiniIndentscopeSymbol = { fg = M.colorset.orange, nocombine = true }
        }

        addHighlightConfig(override_highlight)
        addHighlightConfig(navic_highlight)
        addHighlightConfig(cmp_highlight)
        addHighlightConfig(telescope_highlight)
        addHighlightConfig(leap_highlight)
        addHighlightConfig(marks_highlight)
        addHighlightConfig(illuminate_highlight)
        addHighlightConfig(noice_highlight)
        addHighlightConfig(indentscope_highlight)

        kanagawa.setup({
            transparent = false,
            globalStatus = true,
            terminalColors = false,
            colors = {
                fg_border = M.colorset.white,
                bg = M.colorset.bg,
            },
            overrides = highlight_overrides,
        })

        vim.cmd.colorscheme 'kanagawa'
    end
end

return M
