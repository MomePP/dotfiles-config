local lualine_loadded, lualine = pcall(require, "lualine")
if not lualine_loadded then return end
-- local theme_loadded, plastic_lualine = pcall(require, "lualine.plastic")
-- if not theme_loadded then plastic_lualine = 'auto' end -- set fallback theme

local navic = require('nvim-navic')

local colors = {
    black       = 234,
    white       = 254,
    red         = '#e06c75',
    green       = '#98c379',
    blue        = '#61afef',
    yellow      = '#e5c07b',
    purple      = '#af5fff',
    teal        = '#5bc8af',
    grey        = 236,
    lightgrey   = 238,
    transparent = 'NONE',
}

local conditions = {
    buffer_not_empty = function()
        return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
    end,
    hide_in_width = function()
        return vim.fn.winwidth(0) > 80
    end,
    check_git_workspace = function()
        local filepath = vim.fn.expand('%:p:h')
        local gitdir = vim.fn.finddir('.git', filepath .. ';')
        return gitdir and #gitdir > 0 and #gitdir < #filepath
    end,
}

local mode = {
    "mode",
    fmt = function(mode_string)
        return string.format("%7s", mode_string)
    end,
}

local diagnostics = {
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { "error", "warn" },
    symbols = { error = " ", warn = " " },
    colored = true,
    update_in_insert = false,
    always_visible = true,
}

-- local diff = {
--     "diff",
--     colored = true,
--     symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
--     cond = hide_in_width
-- }

local gps_location = {
    function()
        local gps_text = navic.get_location()
        if #gps_text ~= 0 then
            return ' ' .. gps_text
        else
            return ''
        end
    end,
    color = { fg = colors.purple },
    -- color = { fg = colors.teal },
    cond = navic.is_available
}

-- local filesize = {
--     "filesize",
--     color = { fg = colors.purple },
--     cond = conditions.buffer_not_empty
-- }

local filetype = {
    'filetype',
    icon_only = true,
    separator = '',
    padding = { right = 0, left = 1 }
}

local filename = {
    "filename",
    file_status = false, -- displays file status (readonly status, modified status)
    path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
    color = { gui = 'bold' },
    padding = { right = 0, left = 1 },
    cond = conditions.buffer_not_empty
}

-- local filename_path = {
--     "filename",
--     file_status = true,
--     path = 1
-- }

local branch = {
    "branch",
    icons_enabled = true,
    icon = "",
}

local lsp_status = {
    function()
        local msg = 'no active lsp'
        local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
        local clients = vim.lsp.get_active_clients()
        if next(clients) == nil then
            return msg
        end
        for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                return client.name
            end
        end
        return msg
    end,
    icon = '',
}

local session_status = {
    function()
        local session_name = 'none'
        if vim.v.this_session ~= '' then
            local fname = vim.fn.fnamemodify(vim.v.this_session, ':t')
            local fname_split = vim.split(fname, '__')
            session_name = fname_split[#fname_split]
        end
        return session_name
    end,
    icon = '',
}

local location = {
    function()
        return "[%3l/%3L] :%-2v"
    end
}

local spacing = {
    function()
        return '%='
    end,
}

-- INFO: custom gruvbox light theme
local gruvbox_light = {
    normal = {
        a = { bg = colors.transparent, fg = colors.purple, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.gray },
        c = { bg = colors.transparent, fg = colors.gray },
    },
    insert = {
        a = { bg = colors.green, fg = colors.black, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.gray },
        c = { bg = colors.transparent, fg = colors.gray },
    },
    visual = {
        a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.gray },
        c = { bg = colors.transparent, fg = colors.gray },
    },
    replace = {
        a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.gray },
        c = { bg = colors.transparent, fg = colors.gray },
    },
    command = {
        a = { bg = colors.red, fg = colors.black, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.gray },
        c = { bg = colors.transparent, fg = colors.gray },
    },
    inactive = {
        a = { bg = colors.transparent, fg = colors.lightgrey },
        b = { bg = colors.transparent, fg = colors.lightgrey },
        c = { bg = colors.transparent, fg = colors.lightgrey },
    },
}

-- INFO: custom kanagawa theme
-- local custom_kanagawa = {
--     normal = {
--         a = { bg = colors.transparent, fg = colors.purple, gui = 'bold' },
--         b = { bg = colors.transparent, fg = colors.white },
--         c = { bg = colors.transparent, fg = colors.white },
--     },
--     insert = {
--         a = { bg = colors.green, fg = colors.black, gui = 'bold' },
--         b = { bg = colors.transparent, fg = colors.white },
--         c = { bg = colors.transparent, fg = colors.white },
--     },
--     visual = {
--         a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
--         b = { bg = colors.transparent, fg = colors.white },
--         c = { bg = colors.transparent, fg = colors.white },
--     },
--     replace = {
--         a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
--         b = { bg = colors.transparent, fg = colors.white },
--         c = { bg = colors.transparent, fg = colors.white },
--     },
--     command = {
--         a = { bg = colors.red, fg = colors.black, gui = 'bold' },
--         b = { bg = colors.transparent, fg = colors.white },
--         c = { bg = colors.transparent, fg = colors.white },
--     },
--     inactive = {
--         a = { bg = colors.transparent, fg = colors.lightgrey },
--         b = { bg = colors.transparent, fg = colors.lightgrey },
--         c = { bg = colors.transparent, fg = colors.lightgrey },
--     },
-- }

-- INFO: custom adwaita theme
-- local custom_adwaita = require('lualine.utils.loader').load_theme('adwaita')
-- custom_adwaita.normal.b.bg = 'NONE'
-- custom_adwaita.normal.c.bg = 'NONE'
-- custom_adwaita.insert.b.bg = 'NONE'
-- custom_adwaita.insert.c.bg = 'NONE'
-- custom_adwaita.replace.b.bg = 'NONE'
-- custom_adwaita.replace.c.bg = 'NONE'
-- custom_adwaita.visual.b.bg = 'NONE'

-- INFO: setup lualine configs
lualine.setup({
    options = {
        icons_enabled = true,
        theme = gruvbox_light,
        -- theme = custom_kanagawa,
        -- theme = custom_adwaita,
        section_separators = '',
        component_separators = '',
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { mode },
        lualine_b = { branch },
        lualine_c = { session_status, spacing, filetype, filename, gps_location },
        lualine_x = { diagnostics },
        lualine_y = { lsp_status },
        lualine_z = { location },
    },
    tabline = {},
    extensions = { 'toggleterm' }
})
