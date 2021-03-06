local status_ok, toggleterm = pcall(require, 'toggleterm')
if not status_ok then return end

local toggleterm_keymap = require('keymappings').toggleterm

toggleterm.setup({
	size = 20,
	open_mapping = toggleterm_keymap.toggle,
	shade_terminals = true,
	shading_factor = 2,
	direction = 'float',
	float_opts = {
		border = 'curved',
	},
})


local Terminal = require('toggleterm.terminal').Terminal

local lazygit = Terminal:new({ cmd = 'lazygit', count = 20, hidden = true })
function _LAZYGIT_TOGGLE()
	lazygit:toggle()
end

-- local node = Terminal:new({ cmd = 'node', hidden = true })
-- function _NODE_TOGGLE()
-- 	node:toggle()
-- end
--
-- local ncdu = Terminal:new({ cmd = 'ncdu', hidden = true })
-- function _NCDU_TOGGLE()
-- 	ncdu:toggle()
-- end
--
local gotop = Terminal:new({ cmd = 'gotop', count = 21, hidden = true })
function _GOTOP_TOGGLE()
	gotop:toggle()
end

--
-- local python = Terminal:new({ cmd = 'python', hidden = true })
-- function _PYTHON_TOGGLE()
-- 	python:toggle()
-- end
--

-- local spotify = Terminal:new({ cmd = 'spt', hidden = true })
-- function _SPOTIFY_TOGGLE()
--   spotify:toggle()
-- end

