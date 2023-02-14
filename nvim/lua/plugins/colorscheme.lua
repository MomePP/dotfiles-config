local M = {
    -- 'rebelot/kanagawa.nvim',
    -- 'folke/tokyonight.nvim',
    'catppuccin/nvim', name = 'catppuccin',
    lazy = false,
}

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
    bg_storm    = '#202528',
    bg0         = '#282828',
    bg1         = '#3c3836',
    bg2         = '#504945',
    bg3         = '#665c54',
    transparent = 'NONE',
    error       = '#e82424',
    warn        = '#ff9e3b',
    info        = '#0db9d7',
    hint        = '#4fd699',
}

M.colorset.bracket = {
    '#ffd700',
    '#da70d6',
    '#2ac3de',
}

M.colorset.todocomments = {
    error = M.colorset.error,
    warn  = M.colorset.warn,
    info  = M.colorset.info,
    hint  = M.colorset.hint,
    perf  = '#1085FF',
    todo  = '#B57EDC',
    hack  = '#D19A66',
}

local highlight_overrides = {}

local function overrideHighlightConfig(rhs)
    highlight_overrides = vim.tbl_deep_extend('force', highlight_overrides, rhs)
end

local overrided_highlight_group = {
    WinSeparator = { fg = M.colorset.bg1, bg = M.colorset.transparent },
    SignColumn = { fg = M.colorset.transparent, bg = M.colorset.transparent },
    FloatBorder = { link = 'NormalFloat' },
    MoreMsg = { fg = M.colorset.blue, bg = M.colorset.transparent },
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

local flit_highlight = {
    -- greyout search area of `flit.nvim` by configures `leap.nvim` highlight
    LeapBackdrop = { link = 'LspCodeLens' },
    LeapLabelPrimary = { fg = 'cyan', bold = true, nocombine = true },
    LeapLabelSecondary = { fg = M.colorset.purple, bold = true, nocombine = true },
    LeapMatch = { fg = 'white', bold = true, nocombine = true },
}

local marks_highlight = {
    MarkSignHL = { fg = M.colorset.bright_blue },
    -- MarkVirtTextHL = { fg = M.colorset.bright_blue, bg = M.colorset.transparent, nocombine = true },
}

local local_highlight = {
    LocalHighlightText = { bg = M.colorset.bg1, bold = true, nocombine = true },
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

local incline_highlight = {
    InclineNormal = { fg = vim.o.background ~= 'dark' and M.colorset.black or M.colorset.white,
        bg = M.colorset.transparent, bold = true },
    InclineNormalNC = { fg = M.colorset.gray, bg = M.colorset.transparent, },
    InclineSpacing = { fg = M.colorset.white, bg = M.colorset.orange, },
    InclineModified = { fg = M.colorset.red, bg = M.colorset.transparent, }
}

local lualine_defaults = {
    a = { bg = M.colorset.transparent, gui = 'bold' },
    b = { fg = M.colorset.white, bg = M.colorset.transparent },
    c = { fg = M.colorset.white, bg = M.colorset.transparent },
}

M.colorset.lualine = {
    normal = vim.tbl_deep_extend('force', lualine_defaults, { a = { fg = M.colorset.orange } }),
    insert = vim.tbl_deep_extend('force', lualine_defaults, { a = { fg = M.colorset.green } }),
    visual = vim.tbl_deep_extend('force', lualine_defaults, { a = { fg = M.colorset.magenta } }),
    replace = vim.tbl_deep_extend('force', lualine_defaults, { a = { fg = M.colorset.yellow } }),
    command = vim.tbl_deep_extend('force', lualine_defaults, { a = { fg = M.colorset.red } }),
    inactive = {
        a = { bg = M.colorset.transparent },
        b = { bg = M.colorset.transparent },
        c = { bg = M.colorset.transparent },
    },
}

M.config = function()
    -- INFO: kanagawa theme config
    local kanagawa_status, kanagawa = pcall(require, 'kanagawa')
    if kanagawa_status then
        local kanagawa_colors = require('kanagawa.colors').setup()

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

        overrideHighlightConfig({
            NormalFloat = { bg = M.colorset.bg0 },
            DiagnosticError = { fg = M.colorset.error },
            DiagnosticWarn = { fg = M.colorset.warn },
            DiagnosticInfo = { fg = M.colorset.info },
            DiagnosticHint = { fg = M.colorset.hint },
        })

        overrideHighlightConfig(overrided_highlight_group)
        overrideHighlightConfig(navic_highlight)
        overrideHighlightConfig(cmp_highlight)
        overrideHighlightConfig(telescope_highlight)
        overrideHighlightConfig(flit_highlight)
        overrideHighlightConfig(marks_highlight)
        overrideHighlightConfig(local_highlight)
        overrideHighlightConfig(noice_highlight)
        overrideHighlightConfig(indentscope_highlight)
        overrideHighlightConfig(incline_highlight)

        kanagawa.setup {
            transparent = false,
            globalStatus = true,
            terminalColors = false,
            colors = {
                fg_border = M.colorset.white,
                bg = M.colorset.bg,
            },
            overrides = highlight_overrides,
        }
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'kanagawa'
    end

    local tokyonight_status, tokyonight = pcall(require, 'tokyonight')
    if tokyonight_status then
        local tokyonight_colors = require('tokyonight.colors').setup()

        -- INFO: lualine highlights
        M.colorset.lualine = {
            normal = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = tokyonight_colors.blue2 },
                b = { fg = tokyonight_colors.fg },
                c = { fg = tokyonight_colors.fg },
            }),
            insert = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = tokyonight_colors.green },
                b = { fg = tokyonight_colors.fg },
                c = { fg = tokyonight_colors.fg },
            }),
            visual = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = tokyonight_colors.magenta },
                b = { fg = tokyonight_colors.fg },
                c = { fg = tokyonight_colors.fg },
            }),
            replace = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = tokyonight_colors.yellow },
                b = { fg = tokyonight_colors.fg },
                c = { fg = tokyonight_colors.fg },
            }),
            command = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = tokyonight_colors.red1 },
                b = { fg = tokyonight_colors.fg },
                c = { fg = tokyonight_colors.fg },
            }),
        }

        -- INFO: todo-comments highlights
        M.colorset.todocomments.error = tokyonight_colors.error
        M.colorset.todocomments.warn = tokyonight_colors.warning
        M.colorset.todocomments.info = tokyonight_colors.info
        M.colorset.todocomments.hint = tokyonight_colors.hint

        -- INFO: noice highlights
        noice_highlight.NoiceSplit = { bg = M.colorset.bg_storm }
        noice_highlight.NoiceCmdlineIconCmdline.fg = tokyonight_colors.red1
        noice_highlight.NoiceCmdlineIconFilter.fg = tokyonight_colors.teal
        noice_highlight.NoiceCmdlineIconSearch.fg = tokyonight_colors.yellow

        -- INFO: incline highlights
        incline_highlight.InclineNormal.fg = tokyonight_colors.fg
        incline_highlight.InclineNormalNC.fg = tokyonight_colors.fg_gutter
        incline_highlight.InclineModified.fg = tokyonight_colors.red1
        incline_highlight.InclineSpacing.bg = tokyonight_colors.blue2

        -- INFO: telescope highlights
        telescope_highlight = {
            TelescopeNormal = { fg = tokyonight_colors.fg_dark, bg = M.colorset.bg_storm },
            TelescopePromptTitle = { fg = M.colorset.bg, bg = tokyonight_colors.blue2 },
            TelescopeResultsTitle = { fg = M.colorset.bg, bg = tokyonight_colors.blue2 },
            TelescopePreviewTitle = { fg = M.colorset.bg, bg = tokyonight_colors.blue2 },
        }

        -- INFO: default highlights
        overrided_highlight_group.WinSeparator.fg = M.colorset.bg_storm

        overrideHighlightConfig(noice_highlight)
        overrideHighlightConfig(incline_highlight)
        overrideHighlightConfig(telescope_highlight)
        overrideHighlightConfig(flit_highlight)
        overrideHighlightConfig(marks_highlight)
        overrideHighlightConfig(overrided_highlight_group)

        tokyonight.setup {
            style = 'storm',
            terminal_colors = false,
            on_colors = function(colors)
                colors.bg = M.colorset.bg
                colors.bg_dark = M.colorset.bg_storm
                colors.bg_float = M.colorset.bg_storm
            end,

            on_highlights = function(hl, _)
                for key, value in pairs(highlight_overrides) do
                    hl[key] = value
                end
            end,
        }
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'tokyonight'
    end

    local catppuccin_status, catppuccin = pcall(require, 'catppuccin')
    if catppuccin_status then
        local catppuccin_colors = require('catppuccin.palettes').get_palette 'mocha'

        -- INFO: lualine highlights
        M.colorset.lualine = {
            normal = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = catppuccin_colors.blue },
                b = { fg = catppuccin_colors.text },
                c = { fg = catppuccin_colors.text },
            }),
            insert = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = catppuccin_colors.green },
                b = { fg = catppuccin_colors.text },
                c = { fg = catppuccin_colors.text },
            }),
            visual = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = catppuccin_colors.pink },
                b = { fg = catppuccin_colors.text },
                c = { fg = catppuccin_colors.text },
            }),
            replace = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = catppuccin_colors.yellow },
                b = { fg = catppuccin_colors.text },
                c = { fg = catppuccin_colors.text },
            }),
            command = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = catppuccin_colors.sky },
                b = { fg = catppuccin_colors.text },
                c = { fg = catppuccin_colors.text },
            }),
        }

        -- INFO: telescope highlights
        telescope_highlight = {
            TelescopeNormal = { bg = catppuccin_colors.mantle },
            TelescopeResultsBorder = { bg = catppuccin_colors.mantle },
            TelescopePreviewBorder = { bg = catppuccin_colors.mantle },
            TelescopePromptBorder = { bg = catppuccin_colors.mantle },
            TelescopeSelection = { bg = catppuccin_colors.mantle }
        }

        -- INFO: incline highlights
        incline_highlight = {
            InclineNormal = { fg = catppuccin_colors.text, bg = catppuccin_colors.base, bold = true },
            InclineNormalNC = { fg = catppuccin_colors.surface2, bg = catppuccin_colors.none, },
            InclineSpacing = { fg = catppuccin_colors.none, bg = catppuccin_colors.blue, },
            InclineModified = { fg = catppuccin_colors.red, bg = catppuccin_colors.none, }
        }

        noice_highlight = {
            NoiceCmdlineIconCmdline = { bg = catppuccin_colors.none, fg = catppuccin_colors.sky, bold = true },
            NoiceCmdlineIconSearch = { bg = catppuccin_colors.none, fg = catppuccin_colors.orange, bold = true },
            NoiceCmdlineIconFilter = { bg = catppuccin_colors.none, fg = catppuccin_colors.peach, bold = true },
            NoiceSplit = { bg = catppuccin_colors.base },
        }

        overrideHighlightConfig({
            PmenuSel = { fg = catppuccin_colors.none, bg = catppuccin_colors.mantle },
            Pmenu = { fg = catppuccin_colors.text, bg = catppuccin_colors.base },
            NormalFloat = { bg = catppuccin_colors.mantle },
            FloatBorder = { link = 'NormalFloat' },
            LeapBackdrop = { link = 'LspCodeLens' },
            LocalHighlightText = { bg = catppuccin_colors.mantle, bold = true, nocombine = true },
        })
        overrideHighlightConfig(telescope_highlight)
        overrideHighlightConfig(incline_highlight)
        overrideHighlightConfig(noice_highlight)

        catppuccin.setup {
            flavour = 'mocha', -- latte, frappe, macchiato, mocha
            transparent_background = false,
            term_colors = true,
            integrations = {
                leap = true,
                noice = true,
                treesitter_context = true,
                treesitter = true,
                ts_rainbow = true,
                mason = true,
                markdown = true,
                navic = {
                    enabled = true,
                    custom_bg = 'NONE',
                },
                native_lsp = {
                    enabled = true,
                    virtual_text = {
                        errors = { 'italic' },
                        hints = { 'italic' },
                        warnings = { 'italic' },
                        information = { 'italic' },
                    },
                },
            },
            highlight_overrides = {
                all = highlight_overrides
            }
        }
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'catppuccin'
    end
end

return M
