local toggleterm_keymap = require('config.keymaps').toggleterm

local M = {
	'akinsho/toggleterm.nvim',
}

-- M.init = function()
-- 	function _G.setup_terminal_config()
-- 		-- set terminal keymap
-- 		local key_opts = { buffer = 0 }
-- 		vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], key_opts)
-- 	end
--
-- 	vim.cmd('autocmd! TermOpen term://* lua setup_terminal_config()')
-- end

M.opts = function()
	-- local defaults = require('config').defaults

	return {
		size = 20,
		open_mapping = toggleterm_keymap.toggle,
		shade_terminals = false,
		direction = 'tab',
		-- float_opts = {
		-- 	border = defaults.float_border,
		-- 	width = function() return math.ceil(vim.o.columns * 0.9) - 1 end,
		-- 	height = function() return math.ceil(vim.o.lines * 0.85) - 1 end,
		-- },
		-- highlights = {
		-- 	FloatBorder = { link = 'NormalFloat' },
		-- 	NormalFloat = { link = 'NormalFloat' }
		-- },
	}
end

M.config = function(_, opts)
	require('toggleterm').setup(opts)

	local Terminal = require('toggleterm.terminal').Terminal

	local lazygit = Terminal:new({ cmd = 'lazygit', count = 20 })
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

M.keys = {
	{ toggleterm_keymap.toggle },
	{ toggleterm_keymap.lazygit, '<Cmd>ToggleLazyGit<CR>', silent = true, noremap = true },
}

return M
