local lualine_loadded, lualine = pcall(require, 'lualine')
if not lualine_loadded then return end

local navic_status, navic = pcall(require, 'nvim-navic')
local colors = require('colorscheme').colorset

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
    is_navic_available = function()
        return navic_status
    end,
}

local mode = {
    'mode',
    fmt = function(mode_string)
        return string.format('%-7s', mode_string)
    end,
}

local diagnostics = {
    'diagnostics',
    sources = { 'nvim_diagnostic' },
    sections = { 'error', 'warn' },
    symbols = { error = ' ', warn = ' ' },
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

local navic_location = {
    function()
        local navic_text = navic.get_location()
        if #navic_text ~= 0 then
            return ' ' .. navic_text
        else
            return ''
        end
    end,
    cond = conditions.is_navic_available and navic.is_available
}

local filetype = {
    'filetype',
    icon_only = true,
    separator = '',
    padding = { right = 0, left = 1 }
}

local filename = {
    'filename',
    file_status = false, -- displays file status (readonly status, modified status)
    path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
    color = { gui = 'bold' },
    padding = { right = 0, left = 1 },
    cond = conditions.buffer_not_empty
}

local branch = {
    'branch',
    icons_enabled = true,
    icon = '',
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
        return '[%3l/%3L] :%2v'
    end
}

local spacing = {
    function()
        return '%='
    end,
}

-- INFO: custom dark theme
local lualine_colors = {
    normal = {
        a = { bg = colors.transparent, fg = colors.orange, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.white },
        c = { bg = colors.transparent, fg = colors.white },
    },
    insert = {
        a = { bg = colors.transparent, fg = colors.green, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.white },
        c = { bg = colors.transparent, fg = colors.white },
    },
    visual = {
        a = { bg = colors.transparent, fg = colors.magenta, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.white },
        c = { bg = colors.transparent, fg = colors.white },
    },
    replace = {
        a = { bg = colors.transparent, fg = colors.yellow, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.white },
        c = { bg = colors.transparent, fg = colors.white },
    },
    command = {
        a = { bg = colors.transparent, fg = colors.red, gui = 'bold' },
        b = { bg = colors.transparent, fg = colors.white },
        c = { bg = colors.transparent, fg = colors.white },
    },
    inactive = {
        a = { bg = colors.transparent, fg = colors.black },
        b = { bg = colors.transparent, fg = colors.black },
        c = { bg = colors.transparent, fg = colors.black },
    },
}

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
        theme = lualine_colors,
        -- theme = custom_adwaita,
        section_separators = '',
        component_separators = '',
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { mode },
        lualine_b = { branch },
        lualine_c = { session_status, spacing, filetype, filename, navic_location },
        lualine_x = { diagnostics },
        lualine_y = { lsp_status },
        lualine_z = { location },
    },
    tabline = {},
    extensions = { 'toggleterm' }
})
