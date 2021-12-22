local lualine_loadded, lualine = pcall(require, "lualine")
if not lualine_loadded then return end
local theme_loadded, plastic_lualine = pcall(require, "lualine.plastic")
if not theme_loadded then plastic_lualine = 'auto' end -- set fallback theme

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

lualine.setup({
	options = {
		icons_enabled = true,
		theme = plastic_lualine,
    section_separators = {left = '', right = ''},
    component_separators = {left = '', right = ''},
		disabled_filetypes = { "alpha", "dashboard", "Outline" },
		always_divide_middle = true,
	},
	sections = {
		lualine_a = { 'mode' },
		lualine_b = { branch },
		lualine_c = { filename },
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
	extensions = {'fugitive'},
})
