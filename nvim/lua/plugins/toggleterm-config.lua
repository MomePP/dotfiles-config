local toggleterm_keymap = require('config.keymaps').toggleterm

local M = {
	'akinsho/toggleterm.nvim',
}

-- M.init = function()
-- end

M.init = function()
	local Terminal = require('toggleterm.terminal').Terminal

	vim.api.nvim_create_user_command('ToggleLazyGit',
		function()
			Terminal:new({ cmd = 'lazygit', count = 20 }):toggle()
		end,
		{ desc = 'Toggle `lazygit` terminal using toggleterm' }
	)

	vim.api.nvim_create_user_command('ToggleLazyGitFileHistory',
		function()
			Terminal:new({ cmd = 'lazygit -f ' .. vim.fn.expand('%'), count = 21 }):toggle()
		end,
		{ desc = 'Toggle `lazygit` with filter opened file in current buffer' }
	)

	-- local gotop = Terminal:new({ cmd = 'gotop', count = 21, hidden = true })
	-- local node = Terminal:new({ cmd = 'node', hidden = true })
	-- local ncdu = Terminal:new({ cmd = 'ncdu', hidden = true })
	-- local python = Terminal:new({ cmd = 'python', hidden = true })
	-- local spotify = Terminal:new({ cmd = 'spt', hidden = true })

	-- 	function _G.setup_terminal_config()
	-- 		-- set terminal keymap
	-- 		local key_opts = { buffer = 0 }
	-- 		vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], key_opts)
	-- 	end
	--
	-- 	vim.cmd('autocmd! TermOpen term://* lua setup_terminal_config()')
end

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

M.keys = {
	{ toggleterm_keymap.toggle },
	{ toggleterm_keymap.lazygit,              '<Cmd>ToggleLazyGit<CR>',            silent = true, noremap = true },
	{ toggleterm_keymap.lazygit_file_history, '<Cmd>ToggleLazyGitFileHistory<CR>', silent = true, noremap = true },
}

return M
