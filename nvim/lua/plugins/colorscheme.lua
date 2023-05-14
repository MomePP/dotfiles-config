local M = {
    -- 'rebelot/kanagawa.nvim',
    -- 'folke/tokyonight.nvim',
    -- 'catppuccin/nvim',
    'nyoom-engineering/oxocarbon.nvim',
    name = 'nvim-colorscheme',
    event = 'UIEnter'
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
    error       = '#c53b53',
    warn        = '#ffc777',
    info        = '#0db9d7',
    hint        = '#4fd6be',
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

local function lspDisableHighlight()
    for _, group in ipairs(vim.fn.getcompletion('@lsp', 'highlight')) do
        vim.api.nvim_set_hl(0, group, {})
    end
end


local function overrideHighlightConfig(rhs)
    highlight_overrides = vim.tbl_deep_extend('force', highlight_overrides, rhs)
end

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
        local function kanagawaOverrided(c)
            local palette = c.palette
            local theme = c.theme

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
                LocalHighlight = { bg = M.colorset.bg1, bold = true, nocombine = true },
            }

            local noice_highlight = {
                NoiceCmdlineIconCmdline = { bg = M.colorset.transparent, fg = M.colorset.red, bold = true },
                NoiceCmdlineIconSearch = { bg = M.colorset.transparent, fg = M.colorset.orange, bold = true },
                NoiceCmdlineIconFilter = { bg = M.colorset.transparent, fg = M.colorset.teal, bold = true },
                NoiceSplit = { bg = M.colorset.bg },
            }

            local incline_highlight = {
                InclineNormal = {
                    fg = vim.o.background ~= 'dark' and M.colorset.black or M.colorset.white,
                    bg = M.colorset.transparent,
                    bold = true
                },
                InclineNormalNC = { fg = M.colorset.gray, bg = M.colorset.transparent, },
                InclineSpacing = { fg = M.colorset.white, bg = M.colorset.orange, },
                InclineModified = { fg = M.colorset.red, bg = M.colorset.transparent, }
            }

            local navic_highlight = {
                NavicIconsFile = { fg = palette.springViolet2 },
                NavicIconsModule = { fg = palette.boatYellow2 },
                NavicIconsNamespace = { fg = palette.springViolet2 },
                NavicIconsPackage = { fg = palette.springViolet1 },
                NavicIconsClass = { fg = palette.surimiOrange },
                NavicIconsMethod = { fg = palette.crystalBlue },
                NavicIconsProperty = { fg = palette.waveAqua2 },
                NavicIconsField = { fg = palette.waveAqua1 },
                NavicIconsConstructor = { fg = palette.surimiOrange },
                NavicIconsEnum = { fg = palette.boatYellow2 },
                NavicIconsInterface = { fg = palette.carpYellow },
                NavicIconsFunction = { fg = palette.crystalBlue },
                NavicIconsVariable = { fg = palette.oniViolet },
                NavicIconsConstant = { fg = palette.oniViolet },
                NavicIconsString = { fg = palette.springGreen },
                NavicIconsNumber = { fg = palette.sakuraPink },
                NavicIconsBoolean = { fg = palette.surimiOrange },
                NavicIconsArray = { fg = palette.waveAqua2 },
                NavicIconsObject = { fg = palette.surimiOrange },
                NavicIconsKey = { fg = palette.oniViolet },
                NavicIconsNull = { fg = palette.carpYellow },
                NavicIconsEnumMember = { fg = palette.carpYellow },
                NavicIconsStruct = { fg = palette.surimiOrange },
                NavicIconsEvent = { fg = palette.surimiOrange },
                NavicIconsOperator = { fg = palette.springViolet2 },
                NavicIconsTypeParameter = { fg = palette.springBlue },
                NavicText = { fg = M.colorset.white },
                NavicSeparator = { fg = M.colorset.orange },
            }

            telescope_highlight = {
                TelescopeTitle = { fg = theme.ui.special, bold = true },
                TelescopePromptNormal = { bg = theme.ui.bg_p1 },
                TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
                TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
                TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
                TelescopePreviewNormal = { bg = theme.ui.bg_dim },
                TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
                TelescopeSelection = { bg = theme.ui.bg_dim, bold = true },
                TelescopeResultsDiffAdd = { bg = theme.ui.bg_dim },
                TelescopeResultsDiffChange = { bg = theme.ui.bg_dim },
                TelescopeResultsDiffDelete = { bg = theme.ui.bg_dim },
                TelescopeResultsDiffUntracked = { bg = theme.ui.bg_dim },
            }

            overrideHighlightConfig({
                DiagnosticError = { fg = M.colorset.error },
                DiagnosticWarn = { fg = M.colorset.warn },
                DiagnosticInfo = { fg = M.colorset.info },
                DiagnosticHint = { fg = M.colorset.hint },
            })

            overrideHighlightConfig({
                WinSeparator = { fg = palette.sumiInk4, bg = M.colorset.transparent },
            })
            overrideHighlightConfig(navic_highlight)
            overrideHighlightConfig(cmp_highlight)
            overrideHighlightConfig(telescope_highlight)
            overrideHighlightConfig(flit_highlight)
            overrideHighlightConfig(marks_highlight)
            overrideHighlightConfig(local_highlight)
            overrideHighlightConfig(noice_highlight)
            overrideHighlightConfig(incline_highlight)

            return highlight_overrides
        end

        kanagawa.setup {
            compile = false,
            transparent = false,
            globalStatus = true,
            terminalColors = false,
            colors = {
                theme = {
                    all = {
                        ui = {
                            bg_gutter = 'none',
                        }
                    }
                }
            },
            overrides = kanagawaOverrided,
        }
        kanagawa.load('wave')
    end

    local tokyonight_status, tokyonight = pcall(require, 'tokyonight')
    if tokyonight_status then
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

        overrideHighlightConfig(flit_highlight)
        overrideHighlightConfig(marks_highlight)

        local function on_highlights(hl, c)
            -- INFO: incline highlights
            hl.InclineNormal = { fg = c.fg, bg = c.bg, bold = true }
            hl.InclineNormalNC = { fg = c.comment, bg = c.bg, }
            hl.InclineSpacing = { fg = c.none, bg = c.blue2, }
            hl.InclineModified = { fg = c.red, bg = c.none, }

            -- INFO: noice highlights
            hl.NoiceCmdlineIconCmdline = { bg = c.none, fg = c.blue2, bold = true }
            hl.NoiceCmdlineIconSearch = { bg = c.none, fg = c.orange, bold = true }
            hl.NoiceCmdlineIconFilter = { bg = c.none, fg = c.teal, bold = true }
            hl.NoiceSplit = { link = 'Normal' }

            -- INFO: telescope highlights
            hl.TelescopeNormal = { fg = c.fg_dark, bg = c.bg_dark }
            hl.TelescopePromptTitle = { fg = c.bg_dark, bg = c.blue2, bold = true }
            hl.TelescopeResultsTitle = { fg = c.bg_dark, bg = c.blue2, bold = true }
            hl.TelescopePreviewTitle = { fg = c.bg_dark, bg = c.blue2, bold = true }
            hl.TelescopeSelection = { fg = c.fg, bg = c.bg_dark, bold = true }
            hl.TelescopeResultsDiffAdd = { bg = c.bg_dark }
            hl.TelescopeResultsDiffChange = { bg = c.bg_dark }
            hl.TelescopeResultsDiffDelete = { bg = c.bg_dark }
            hl.TelescopeResultsDiffUntracked = { bg = c.bg_dark }

            -- INFO: ts rainbow 2 highlight
            hl.TSRainbowRed = { link = 'rainbowcol1' }
            hl.TSRainbowYellow = { link = 'rainbowcol2' }
            hl.TSRainbowBlue = { link = 'rainbowcol3' }
            hl.TSRainbowOrange = { link = 'rainbowcol4' }
            hl.TSRainbowGreen = { link = 'rainbowcol5' }
            hl.TSRainbowViolet = { link = 'rainbowcol6' }
            hl.TSRainbowCyan = { link = 'rainbowcol7' }

            -- INFO: lsp diagnostics virtual text highlight
            hl.DiagnosticVirtualTextError = { bg = '#322639', fg = M.colorset.error, italic = true }
            hl.DiagnosticVirtualTextWarn = { bg = '#38343d', fg = M.colorset.warn, italic = true }
            hl.DiagnosticVirtualTextInfo = { bg = '#203346', fg = M.colorset.info, italic = true }
            hl.DiagnosticVirtualTextHint = { bg = '#273644', fg = M.colorset.hint, italic = true }

            hl.WinSeparator = { fg = c.border_highlight }
            hl.NormalFloat = { bg = c.bg_float }
            hl.FloatBorder = { link = 'NormalFloat' }
            hl.LocalHighlight = { bg = c.bg_highlight, bold = true, nocombine = true }

            -- INFO: lualine highlights
            M.colorset.lualine = {
                normal = vim.tbl_deep_extend('force', lualine_defaults, {
                    a = { fg = c.cyan },
                    b = { fg = c.fg },
                    c = { fg = c.fg },
                }),
                insert = vim.tbl_deep_extend('force', lualine_defaults, {
                    a = { fg = c.green },
                    b = { fg = c.fg },
                    c = { fg = c.fg },
                }),
                visual = vim.tbl_deep_extend('force', lualine_defaults, {
                    a = { fg = c.magenta },
                    b = { fg = c.fg },
                    c = { fg = c.fg },
                }),
                replace = vim.tbl_deep_extend('force', lualine_defaults, {
                    a = { fg = c.yellow },
                    b = { fg = c.fg },
                    c = { fg = c.fg },
                }),
                command = vim.tbl_deep_extend('force', lualine_defaults, {
                    a = { fg = c.blue2 },
                    b = { fg = c.fg },
                    c = { fg = c.fg },
                }),
            }

            -- INFO: todo-comments highlights
            M.colorset.todocomments.error = c.error
            M.colorset.todocomments.warn = c.warning
            M.colorset.todocomments.info = c.info
            M.colorset.todocomments.hint = c.hint

            for key, value in pairs(highlight_overrides) do
                hl[key] = value
            end
        end

        tokyonight.setup {
            style = 'moon',
            terminal_colors = true,
            on_highlights = on_highlights,
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
        local telescope_highlight = {
            TelescopeNormal = { bg = catppuccin_colors.mantle },
            TelescopeResultsBorder = { bg = catppuccin_colors.mantle },
            TelescopePreviewBorder = { bg = catppuccin_colors.mantle },
            TelescopePromptBorder = { bg = catppuccin_colors.mantle },
            TelescopeSelection = { bg = catppuccin_colors.mantle },
            TelescopeResultsDiffAdd = { bg = catppuccin_colors.mantle },
            TelescopeResultsDiffChange = { bg = catppuccin_colors.mantle },
            TelescopeResultsDiffDelete = { bg = catppuccin_colors.mantle },
            TelescopeResultsDiffUntracked = { bg = catppuccin_colors.mantle }
        }

        -- INFO: incline highlights
        local incline_highlight = {
            InclineNormal = { fg = catppuccin_colors.text, bg = catppuccin_colors.base, bold = true },
            InclineNormalNC = { fg = catppuccin_colors.surface2, bg = catppuccin_colors.none, },
            InclineSpacing = { fg = catppuccin_colors.none, bg = catppuccin_colors.blue, },
            InclineModified = { fg = catppuccin_colors.red, bg = catppuccin_colors.none, }
        }

        -- INFO: noice highlights
        local noice_highlight = {
            NoiceCmdlineIconCmdline = { bg = catppuccin_colors.none, fg = catppuccin_colors.sky, bold = true },
            NoiceCmdlineIconSearch = { bg = catppuccin_colors.none, fg = catppuccin_colors.orange, bold = true },
            NoiceCmdlineIconFilter = { bg = catppuccin_colors.none, fg = catppuccin_colors.peach, bold = true },
            NoiceSplit = { bg = catppuccin_colors.base },
        }

        local flit_highlight = {
            -- greyout search area of `flit.nvim` by configures `leap.nvim` highlight
            LeapBackdrop = { link = 'LspCodeLens' },
            LeapLabelPrimary = { fg = 'cyan', bold = true, nocombine = true },
            LeapLabelSecondary = { fg = M.colorset.purple, bold = true, nocombine = true },
            LeapMatch = { fg = 'white', bold = true, nocombine = true },
        }

        overrideHighlightConfig({
            PmenuSel = { fg = catppuccin_colors.none, bg = catppuccin_colors.mantle },
            Pmenu = { fg = catppuccin_colors.text, bg = catppuccin_colors.base },
            NormalFloat = { bg = catppuccin_colors.mantle },
            FloatBorder = { link = 'NormalFloat' },
            LocalHighlight = { bg = catppuccin_colors.surface0, bold = true, nocombine = true },
        })
        overrideHighlightConfig(telescope_highlight)
        overrideHighlightConfig(incline_highlight)
        overrideHighlightConfig(noice_highlight)
        overrideHighlightConfig(flit_highlight)

        catppuccin.setup {
            flavour = 'mocha', -- latte, frappe, macchiato, mocha
            transparent_background = false,
            term_colors = true,
            integrations = {
                cmp = true,
                gitsigns = true,
                noice = true,
                treesitter_context = true,
                treesitter = true,
                ts_rainbow2 = true,
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

    local oxocarbon_status, oxocarbon = pcall(require, 'oxocarbon')
    if oxocarbon_status then
        local c = oxocarbon.oxocarbon

        M.colorset.lualine = {
            normal = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = c.base08 },
                b = { fg = c.base04 },
                c = { fg = c.base04 },
            }),
            insert = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = c.base10 },
                b = { fg = c.base04 },
                c = { fg = c.base04 },
            }),
            visual = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = c.base14 },
                b = { fg = c.base04 },
                c = { fg = c.base04 },
            }),
            replace = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = c.base11 },
                b = { fg = c.base04 },
                c = { fg = c.base04 },
            }),
            command = vim.tbl_deep_extend('force', lualine_defaults, {
                a = { fg = c.base12 },
                b = { fg = c.base04 },
                c = { fg = c.base04 },
            }),
        }
        vim.opt.background = 'dark'
        vim.cmd.colorscheme 'oxocarbon'

        local incline_highlight = {
            InclineNormal = { bold = true },
            InclineNormalNC = { fg = c.base03 },
            InclineSpacing = { fg = c.none, bg = c.base10, },
            InclineModified = { fg = c.base10, bg = c.none, },
        }

        local noice_highlight = {
            NoiceCmdlineIconCmdline = { link = 'lualine_a_command' },
            NoiceCmdlineIconSearch = { link = 'lualine_a_command' },
            NoiceCmdlineIconFilter = { link = 'lualine_a_command' },
            NoiceMini = { bg = c.base01 },
            NoiceCmdline = { bg = c.base01 },
            NoiceSplit = { bg = c.base01 },
        }

        local telescope_highlight = {
            TelescopeNormal = { fg = c.base03, bg = c.base00 },
            TelescopeSelection = { fg = c.base04, bold = true },
            TelescopeResultsBorder = { bg = c.base00 },
            TelescopePreviewBorder = { bg = c.base00 },
            TelescopeResultsTitle = { fg = c.base00, bg = c.base00 },
            TelescopeResultsDiffAdd = { bg = c.base00 },
            TelescopeResultsDiffChange = { bg = c.base00 },
            TelescopeResultsDiffDelete = { bg = c.base00 },
            TelescopeResultsDiffUntracked = { bg = c.base00 },
            TelescopeMatching = { link = 'Search' },
        }

        local flit_highlight = {
            LeapBackdrop = { fg = c.base03, bg = c.none },
            LeapLabelPrimary = { fg = 'cyan', bold = true, nocombine = true },
            LeapLabelSecondary = { fg = M.colorset.purple, bold = true, nocombine = true },
            LeapMatch = { fg = 'white', bold = true, nocombine = true },
        }

        local diagnostic_highlight = {
            DiagnosticError = { fg = M.colorset.error },
            DiagnosticWarn = { fg = M.colorset.warn },
            DiagnosticInfo = { fg = M.colorset.info },
            DiagnosticHint = { fg = M.colorset.hint },
            DiagnosticUnderlineError = { fg = M.colorset.error, undercurl = true },
            DiagnosticUnderlineWarn = { fg = M.colorset.warn, undercurl = true },
            DiagnosticUnderlineInfo = { fg = M.colorset.info, undercurl = true },
            DiagnosticUnderlineHint = { fg = M.colorset.hint, undercurl = true },
            DiagnosticVirtualTextError = { bg = '#322639', fg = M.colorset.error, italic = true },
            DiagnosticVirtualTextWarn = { bg = '#38343d', fg = M.colorset.warn, italic = true },
            DiagnosticVirtualTextInfo = { bg = '#203346', fg = M.colorset.info, italic = true },
            DiagnosticVirtualTextHint = { bg = '#273644', fg = M.colorset.hint, italic = true },
        }

        local ts_rainbow_highlight = {
            TSRainbowRed = { fg = c.base10 },
            TSRainbowBlue = { fg = c.base11 },
            TSRainbowCyan = { fg = c.base08 },
            TSRainbowGreen = { fg = c.base13 },
            TSRainbowYellow = { fg = '#FFAB91' },
            TSRainbowOrange = { fg = '#FF6F00' },
            TSRainbowViolet = { fg = c.base14 },
        }

        local indentblankline_highlight = {
            IndentBlanklineContextChar = { fg = c.base04, nocombine = true }
        }

        local ts_context_highlight = {
            TreesitterContext = { bg = c.base02, italic = true },
            TreesitterContextLineNumber = { link = 'TreesitterContext' },
        }

        local cmp_highlight = {
            CmpItemAbbrDeprecated = { fg = c.base03, bg = c.none, strikethrough = true },
            CmpItemAbbrMatch = { fg = c.base05, bg = c.none, bold = true },
            CmpItemAbbrMatchFuzzy = { fg = c.base05, bg = c.none, bold = true },
            CmpItemMenu = { fg = c.base10, bg = c.none, italic = true },
            CmpItemKindInterface = { fg = c.base08, bg = c.none },
            CmpItemKindColor = { fg = c.base08, bg = c.none },
            CmpItemKindTypeParameter = { fg = c.base08, bg = c.none },
            CmpItemKindText = { fg = c.base09, bg = c.none },
            CmpItemKindEnum = { fg = c.base09, bg = c.none },
            CmpItemKindKeyword = { fg = c.base09, bg = c.none },
            CmpItemKindConstant = { fg = c.base10, bg = c.none },
            CmpItemKindConstructor = { fg = c.base10, bg = c.none },
            CmpItemKindReference = { fg = c.base10, bg = c.none },
            CmpItemKindFunction = { fg = c.base11, bg = c.none },
            CmpItemKindStruct = { fg = c.base11, bg = c.none },
            CmpItemKindClass = { fg = c.base11, bg = c.none },
            CmpItemKindModule = { fg = c.base11, bg = c.none },
            CmpItemKindOperator = { fg = c.base11, bg = c.none },
            CmpItemKindField = { fg = c.base12, bg = c.none },
            CmpItemKindProperty = { fg = c.base12, bg = c.none },
            CmpItemKindEvent = { fg = c.base12, bg = c.none },
            CmpItemKindUnit = { fg = c.base13, bg = c.none },
            CmpItemKindSnippet = { fg = c.base13, bg = c.none },
            CmpItemKindFolder = { fg = c.base13, bg = c.none },
            CmpItemKindVariable = { fg = c.base14, bg = c.none },
            CmpItemKindFile = { fg = c.base14, bg = c.none },
            CmpItemKindMethod = { fg = c.base15, bg = c.none },
            CmpItemKindValue = { fg = c.base15, bg = c.none },
            CmpItemKindEnumMember = { fg = c.base15, bg = c.none },
        }

        local local_highlight = {
            LocalHighlight = { bg = c.base02, bold = true, nocombine = true },
        }

        overrideHighlightConfig({
            Normal = { fg = c.base04, bg = c.none },
            NormalNC = { fg = c.base04, bg = c.none },
            LineNr = { fg = c.base03, bg = c.none },
            FoldColumn = { fg = c.base02, bg = c.none },
            SignColumn = { fg = c.base02, bg = c.none },
            CursorLine = { bg = c.base02 },
            VertSplit = { fg = c.base02, bg = c.none },
            NormalFloat = { bg = c.base00 },
            FloatBorder = { link = 'NormalFloat' },
            FloatTitle = { fg = c.base10, bg = c.base00, bold = true },
            Pmenu = { fg = c.base04, bg = c.base00 },
            PmenuSel = { fg = c.none, bg = c.base02 },
            Search = { fg = c.base01, bg = c.base12, bold = true },
        })
        overrideHighlightConfig(telescope_highlight)
        overrideHighlightConfig(incline_highlight)
        overrideHighlightConfig(noice_highlight)
        overrideHighlightConfig(flit_highlight)
        overrideHighlightConfig(diagnostic_highlight)
        overrideHighlightConfig(ts_rainbow_highlight)
        overrideHighlightConfig(indentblankline_highlight)
        overrideHighlightConfig(ts_context_highlight)
        overrideHighlightConfig(cmp_highlight)
        overrideHighlightConfig(local_highlight)

        for hl_name, hl_value in pairs(highlight_overrides) do
            vim.api.nvim_set_hl(0, hl_name, hl_value)
        end

        -- INFO: disable lsp semantic token highlighting
        lspDisableHighlight()

        -- INFO: overrided some terminal colors
        vim.g['terminal_color_3'] = c.base10
        vim.g['terminal_color_5'] = '#ffab91'
        vim.g['terminal_color_9'] = c.base15
        vim.g['terminal_color_11'] = c.base12
        vim.g['terminal_color_13'] = '#ff6f00'
    end
end

return M
