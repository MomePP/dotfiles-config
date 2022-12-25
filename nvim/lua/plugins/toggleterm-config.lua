local toggleterm_keymap = require('keymaps').toggleterm

local M = {
	'akinsho/toggleterm.nvim',
	keys = {
		{ toggleterm_keymap.toggle },
		{ toggleterm_keymap.lazygit, '<Cmd>ToggleLazyGit<CR>', toggleterm_keymap.opts }
	}
}

M.config = function()
	local toggleterm = require('toggleterm')
	toggleterm.setup({
		size = 20,
		open_mapping = toggleterm_keymap.toggle,
		shade_terminals = false,
		direction = 'float',
		float_opts = {
			border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
		},
		highlights = {
			FloatBorder = { link = 'FloatBorder' },
			NormalFloat = { link = 'NormalFloat' }
		}
	})

	local Terminal = require('toggleterm.terminal').Terminal

	local lazygit = Terminal:new({ cmd = 'lazygit', count = 20, hidden = true })
	vim.api.nvim_create_user_command('ToggleLazyGit',
		function()
			lazygit:toggle()
		end,
		{ desc = 'Toggle `lazygit` terminal using toggleterm' }
	)

	-- local gotop = Terminal:new({ cmd = 'gotop', count = 21, hidden = true })
	-- local node = Terminal:new({ cmd = 'node', hidden = true })
	-- local ncdu = Terminal:new({ cmd = 'ncdu', hidden = true })
	-- local python = Terminal:new({ cmd = 'python', hidden = true })
	-- local spotify = Terminal:new({ cmd = 'spt', hidden = true })
end

return M
