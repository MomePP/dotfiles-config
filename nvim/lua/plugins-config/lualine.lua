local lualine_loadded, lualine = pcall(require, "lualine")
if not lualine_loadded then return end
-- local theme_loadded, plastic_lualine = pcall(require, "lualine.plastic")
-- if not theme_loadded then plastic_lualine = 'auto' end -- set fallback theme

local colors = {
  black        = 234,
  white        = 252,
  red          = '#e06c75',
  green        = '#98c379',
  blue         = '#61afef',
  yellow       = '#e5c07b',
  purple       = '#b57edc',
  grey         = 236,
  lightgrey    = 238,
  inactivegrey = 'NONE',
}

local hide_in_width = function()
	return vim.fn.winwidth(0) > 80
end

local diagnostics = {
	"diagnostics",
	sources = { "nvim_diagnostic" },
	sections = { "error", "warn" },
	symbols = { error = " ", warn = " " },
	colored = true,
	update_in_insert = false,
	always_visible = true,
}

local diff = {
	"diff",
	colored = true,
	symbols = { added = " ", modified = " ", removed = " " }, -- changes diff symbols
    cond = hide_in_width
}

local filetype = {
	"filetype",
	icons_enabled = true,
}

local filename = {
    "filename",
    file_status = true, -- displays file status (readonly status, modified status)
    path = 0            -- 0 = just filename, 1 = relative path, 2 = absolute path
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

local spacing = {
  function()
    return '%='
  end,
}

local lsp_status = {
    function()
        local msg = 'No Active Lsp'
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
    icon = ' LSP:',
    color = { fg = colors.white , gui = 'bold' },
}

lualine.setup({
    options = {
        icons_enabled = true,
        -- theme = plastic_lualine,
        theme = {
            normal = {
                a = { bg = colors.white, fg = colors.black, gui = 'bold' },
                b = { bg = colors.grey, fg = colors.white },
                c = { bg = colors.black, fg = colors.white },
            },
            insert = {
                a = { bg = colors.green, fg = colors.black, gui = 'bold' },
                b = { bg = colors.grey, fg = colors.white },
                c = { bg = colors.black, fg = colors.white },
            },
            visual = {
                a = { bg = colors.purple, fg = colors.black, gui = 'bold' },
                b = { bg = colors.grey, fg = colors.white },
                c = { bg = colors.black, fg = colors.white },
            },
            replace = {
                a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
                b = { bg = colors.grey, fg = colors.white },
                c = { bg = colors.black, fg = colors.white },
            },
            command = {
                a = { bg = colors.red, fg = colors.black, gui = 'bold' },
                b = { bg = colors.grey, fg = colors.white },
                c = { bg = colors.black, fg = colors.white },
            },
            inactive = {
                a = { bg = colors.inactivegrey, fg = colors.lightgrey, gui = 'bold' },
                b = { bg = colors.inactivegrey, fg = colors.lightgrey },
                c = { bg = colors.inactivegrey, fg = colors.lightgrey },
            },
        },
        section_separators = {left = '', right = ''},
        component_separators = '',
        disabled_filetypes = { "alpha", "dashboard", "Outline" },
        always_divide_middle = true,
    },
    sections = {
        lualine_a = { 'mode' },
        lualine_b = { branch },
        lualine_c = { filename, spacing, lsp_status },
        lualine_x = { diagnostics, diff },
        lualine_y = { filetype },
        lualine_z = { 'location' },
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { filename_path },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
    },
    tabline = {},
})
