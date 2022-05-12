local status_sta, staline = pcall(require, 'staline')
if not status_sta then return end

local colors = {
    white        = '#eeeeee',
    red          = '#E06C75',
    green        = '#8fbf7f',
    olive        = '#84a598',
    blue         = '#0087ff',
    cream        = '#E6CCA9',
    yellow       = '#E9D16C',
    purple       = '#af5fff',
    orange       = '#fc802d',
    gray         = '#5f6672',
    darkgray     = '#21252b',
    transparent  = 'NONE',
}

staline.setup {
    sections = {
		left = { ' ', 'mode', ' ', 'branch', '  ', function () return "神" .. require('auto-session-library').current_session_name() end },
		mid = { 'file_name', '', 'file_size' },
		right = { '-lsp', ' ', 'lsp_name', ' ', 'line_column' }
	},
	mode_colors = {
		i = colors.green,
		n = colors.cream,
		c = colors.red,
		v = colors.purple,
        V = colors.orange,
        t = colors.blue,
	},
    mode_icons = {
		n = " ",
		v = " ",   -- etc..
	},
	defaults = {
		true_colors = true,
		line_column = " [%l/%L] :%c",
		branch_symbol = " ",
	},
    special_table = {
        toggleterm = { 'ToggleTerm', ' ' }
    }
}

-- require'stabline'.setup {
--     style       = "bar", -- others: arrow, slant, bubble
--     stab_left   = "",   -- 😬
--     stab_right  = "",
--
--     fg          = colors.darkgray, -- is fg of "Normal".
--     bg          = colors.green, -- is bg of "Normal".
--     inactive_fg = colors.gray,
--     inactive_bg = colors.transparent,
--
--     font_active = 'bold',
-- }
