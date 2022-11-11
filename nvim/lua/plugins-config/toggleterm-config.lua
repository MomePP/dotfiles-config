local status_ok, toggleterm = pcall(require, 'toggleterm')
if not status_ok then return end

local toggleterm_keymap = require('keymappings').toggleterm
local colors = require('colorscheme').colorset

toggleterm.setup({
	size = 20,
	open_mapping = toggleterm_keymap.toggle,
	shade_terminals = true,
	shading_factor = 2,
	direction = 'float',
	float_opts = {
		border = 'curved',
	},
	highlights = {
		FloatBorder = {
			guifg = colors.white,
			guibg = colors.transparent,
		}
	}
})


local Terminal = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new({ cmd = 'lazygit', count = 20, hidden = true })
vim.keymap.set('n', toggleterm_keymap.lazygit,
	function()
		lazygit:toggle()
	end, toggleterm_keymap.opts)

-- local gotop = Terminal:new({ cmd = 'gotop', count = 21, hidden = true })
-- vim.keymap.set('n', toggleterm_keymaps.gotop,
-- 	function()
-- 		gotop:toggle()
-- 	end, toggleterm_keymaps.opts)

-- local node = Terminal:new({ cmd = 'node', hidden = true })
-- local ncdu = Terminal:new({ cmd = 'ncdu', hidden = true })
-- local python = Terminal:new({ cmd = 'python', hidden = true })
-- local spotify = Terminal:new({ cmd = 'spt', hidden = true })
