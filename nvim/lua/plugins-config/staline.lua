local status_sta, staline = pcall(require, 'staline')
if not status_sta then return end

local colors = {
    white        = '#eeeeee',
    red          = '#D74E42',
    green        = '#8fbf7f',
    olive        = '#84a598',
    blue         = '#61afef',
    cream        = '#d4be98',
    yellow       = '#E9D16C',
    purple       = '#b57edc',
    orange       = '#fc802d',
    gray         = '#5f6672',
    darkgray     = '#21252b',
    transparent  = 'NONE',
}

local time = function()
  return os.date("%a │ %H:%M %x")
end

staline.setup {
    sections = {
		left = { ' ', 'mode', ' ', 'branch' },
		mid = { '-lsp' },
		right = { 'file_name', ' ', 'line_column' }
	},
	mode_colors = {
		i = colors.green,
		n = colors.white,
		c = colors.red,
        v = colors.yellow,
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
