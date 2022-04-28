local status_sta, staline = pcall(require, 'staline')
if not status_sta then return end

local colors = {
    white        = '#eeeeee',
    red          = '#E06C75',
    green        = '#8fbf7f',
    olive        = '#84a598',
    blue         = '#6FDFDF',
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
		left = { ' ', 'mode', ' ', 'branch' },
		mid = { '-lsp' },
		right = { 'file_name', ' ', 'line_column' }
	},
	mode_colors = {
		i = colors.green,
		n = colors.cream,
		c = colors.red,
		v = colors.purple,
        V = colors.orange,
	},
	defaults = {
		true_colors = true,
		line_column = " [%l/%L] :%c",
		branch_symbol = " ",
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
