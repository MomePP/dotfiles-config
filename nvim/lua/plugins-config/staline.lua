local status_sta, staline = pcall(require, 'staline')
if not status_sta then return end

local colors = {
    white        = '#e4e4e4',
    red          = '#E06C75',
    green        = '#8fbf7f',
    olive        = '#84a598',
    blue         = '#0087ff',
    cream        = '#E6CCA9',
    yellow       = '#E5C07B',
    purple       = '#af5fff',
    orange       = '#fc802d',
    gray         = '#a8a8a8',
    darkgray     = '#21252b',
    transparent  = 'NONE',
}

staline.setup {
    sections = {
        left = {
            ' ',
            { 'StalineMode', 'mode' },
            ' ',
            'branch',
            '  ',
            function ()
                local session_name = 'none'
                if vim.v.this_session ~= '' then
                    session_name = require('auto-session-library').current_session_name()
                end
                return "神" .. session_name
            end,
        },
        mid = {
            'file_name',
            '',
            { 'StalineFileSize', 'file_size' }
        },
        right = {
            '-lsp',
            ' ',
            { 'StalineLSP', 'lsp_name' },
            ' ',
            'line_column'
        }
	},
	mode_colors = {
		i = colors.gray,
		n = colors.white,
		c = colors.gray,
		v = colors.gray,
        V = colors.gray,
        t = colors.gray,
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

vim.cmd("hi StalineMode guifg=" .. colors.purple)
vim.cmd("hi StalineSession guifg=" .. colors.purple)
vim.cmd("hi StalineFileSize guifg=" .. colors.purple)
vim.cmd("hi StalineLSP guifg=" .. colors.purple)

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
