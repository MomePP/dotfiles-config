local lualine_loadded, lualine = pcall(require, "lualine")
if not lualine_loadded then return end
-- local theme_loadded, plastic_lualine = pcall(require, "lualine.plastic")
-- if not theme_loadded then plastic_lualine = 'auto' end -- set fallback theme

local gps = require('nvim-gps')

local colors = {
    black       = 234,
    white       = 254,
    red         = '#e06c75',
    green       = '#98c379',
    blue        = '#61afef',
    yellow      = '#e5c07b',
    purple      = '#af5fff',
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
        local gps_text = gps.get_location()
        if #gps_text ~= 0 then
            return '> ' .. gps_text
        else
            return ''
        end
    end,
    color = { fg = colors.purple },
    cond = gps.is_available
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

local filename_path = {
    "filename",
    file_status = true,
    path = 1
}

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
    color = { fg = colors.white },
}

local session_status = {
    function()
        local session_name = 'none'
        if vim.v.this_session ~= '' then
            session_name = require('auto-session-library').current_session_name()
        end
        return session_name
    end,
    icon = '',
    color = { fg = colors.white }
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

lualine.setup({
    options = {
        icons_enabled = true,
        -- theme = plastic_lualine,
        theme = {
            normal = {
                a = { bg = colors.transparent, fg = colors.purple, gui = 'bold' },
                b = { bg = colors.transparent, fg = colors.white },
                c = { bg = colors.transparent, fg = colors.white },
            },
            insert = {
                a = { bg = colors.green, fg = colors.black, gui = 'bold' },
                b = { bg = colors.transparent, fg = colors.white },
                c = { bg = colors.transparent, fg = colors.white },
            },
            visual = {
                a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
                b = { bg = colors.transparent, fg = colors.white },
                c = { bg = colors.transparent, fg = colors.white },
            },
            replace = {
                a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
                b = { bg = colors.transparent, fg = colors.white },
                c = { bg = colors.transparent, fg = colors.white },
            },
            command = {
                a = { bg = colors.red, fg = colors.black, gui = 'bold' },
                b = { bg = colors.transparent, fg = colors.white },
                c = { bg = colors.transparent, fg = colors.white },
            },
            inactive = {
                a = { bg = colors.transparent, fg = colors.lightgrey },
                b = { bg = colors.transparent, fg = colors.lightgrey },
                c = { bg = colors.transparent, fg = colors.lightgrey },
            },
        },
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
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { filename_path },
        lualine_x = { location },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
    extensions = { 'toggleterm' }
})
