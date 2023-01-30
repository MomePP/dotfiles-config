local toggleterm_keymap = require('config.keymaps').toggleterm

local M = {
	'akinsho/toggleterm.nvim',
}

M.opts = function()
	local defaults = require('config').defaults

	return {
		size = 20,
		open_mapping = toggleterm_keymap.toggle,
		shade_terminals = false,
		direction = 'float',
		float_opts = {
			border = defaults.float_border,
			width = function() return math.ceil(vim.o.columns * 0.9) end,
			height = function() return math.ceil(vim.o.lines * 0.85) - 1 end,
		},
		highlights = {
			FloatBorder = { link = 'NormalFloat' },
			NormalFloat = { link = 'NormalFloat' }
		}
	}
end

-- M.config = function()
-- 	-- local Terminal = require('toggleterm.terminal').Terminal
-- 	--
-- 	-- local lazygit = Terminal:new({ cmd = 'lazygit', count = 20, hidden = true })
-- 	-- vim.api.nvim_create_user_command('ToggleLazyGit',
-- 	-- 	function()
-- 	-- 		lazygit:toggle()
-- 	-- 	end,
-- 	-- 	{ desc = 'Toggle `lazygit` terminal using toggleterm' }
-- 	-- )
-- 	--
-- 	-- local gotop = Terminal:new({ cmd = 'gotop', count = 21, hidden = true })
-- 	-- local node = Terminal:new({ cmd = 'node', hidden = true })
-- 	-- local ncdu = Terminal:new({ cmd = 'ncdu', hidden = true })
-- 	-- local python = Terminal:new({ cmd = 'python', hidden = true })
-- 	-- local spotify = Terminal:new({ cmd = 'spt', hidden = true })
-- end

M.keys = {
	{ toggleterm_keymap.toggle },
}

return M
