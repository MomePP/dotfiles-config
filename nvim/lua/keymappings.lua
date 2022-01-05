local utils = require('utils')
local remap = { noremap = false }
local silent_noremap = { noremap = true, silent = true }

utils.map('n', '<C-l>', '<cmd>nohl<cr>')  -- clear highlight
utils.map('n', 'dw', 'vb"_d')             -- delete a word backward
utils.map('n', '<leader>d', '"_d')        -- delete without yank
utils.map('n', 'x', '"_x')
utils.map('v', 'p', '"_dP')               -- replace-paste without yank
utils.map('i', '<S-Tab>', '<C-d>')        -- de-tab while in insert mode
utils.map('n', '<C-a>', 'gg<S-v>G')       -- visual - select all
utils.map('n', 'Y', 'y$')                 -- Yank line after cursor
utils.map('n', 'P', '<cmd>pu<cr>', remap) -- Paste on new line

-- map shift scroll wheel to scroll horizontal
utils.map('', '<S-ScrollWheelUp>', 'zh')
utils.map('', '<S-2-ScrollWheelUp>', '2zh')
utils.map('', '<S-3-ScrollWheelUp>', '3zh')
utils.map('', '<S-4-ScrollWheelUp>', '4zh')
utils.map('', '<S-ScrollWheelDown>', 'zl')
utils.map('', '<S-2-ScrollWheelDown>', '2zl')
utils.map('', '<S-3-ScrollWheelDown>', '3zl')
utils.map('', '<S-4-ScrollWheelDown>', '4zl')

-- Keeping cursor centered
utils.map('n', 'n', 'nzzzv')
utils.map('n', 'N', 'Nzzzv')
utils.map('n', 'J', 'mzJ`z')

-- add undo break points
utils.map('i', ',', ',<C-g>u')
utils.map('i', '.', '.<C-g>u')
utils.map('i', '!', '!<C-g>u')
utils.map('i', '?', '?<C-g>u')

-- Jumplist mutation
utils.map('n', 'k', '(v:count > 5 ? "m\'" . v:count : "") . "k"', { noremap = true, expr = true })
utils.map('n', 'j', '(v:count > 5 ? "m\'" . v:count : "") . "j"', { noremap = true, expr = true })

-- Bufferline config
utils.map('n', '<Tab>', ':BufferLineCycleNext<CR>', silent_noremap)
utils.map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', silent_noremap)
utils.map('n', 'tp', ':BufferLinePick<CR>', silent_noremap)
utils.map('n', 'tq', ':Bdelete<CR>', silent_noremap)

-- Window config
-- split window
utils.map('n', 'ss', '<cmd>split<cr><Space>')
utils.map('n', 'sv', '<cmd>vsplit<cr><Space>')

-- move window
utils.map('n', 'sq', '<C-w>q')
utils.map('n', '<Space>', '<C-w>w')

utils.map('n', 's<left>', '<C-w>h')
utils.map('n', 's<right>', '<C-w>l')
utils.map('n', 's<up>', '<C-w>k')
utils.map('n', 's<down>', '<C-w>j')

utils.map('n', 'sh', '<C-w>h')
utils.map('n', 'sl', '<C-w>l')
utils.map('n', 'sk', '<C-w>k')
utils.map('n', 'sj', '<C-w>j')

-- resize window
utils.map('n', '<C-w><left>', '<C-w><')
utils.map('n', '<C-w><right>', '<C-w>>')
utils.map('n', '<C-w><up>', '<C-w>+')
utils.map('n', '<C-w><down>', '<C-w>-')

-- move line or visually selected block - opt+j/k - must set iterm to esc+
utils.map('i', '<m-j>', '<Esc>:m .+1<CR>==gi')
utils.map('i', '<m-k>', '<Esc>:m .-2<CR>==gi')
utils.map('i', '<m-down>', '<Esc>:m .+1<CR>==gi')
utils.map('i', '<m-up>', '<Esc>:m .-2<CR>==gi')

utils.map('v', '<m-k>', ':m \'<-2<CR>gv=gv')
utils.map('v', '<m-j>', ':m \'>+1<CR>gv=gv')
utils.map('v', '<m-down>', ':m \'>+1<CR>gv=gv')
utils.map('v', '<m-up>', ':m \'<-2<CR>gv=gv')

utils.map('n', '<m-j>', ':m+<CR>')
utils.map('n', '<m-k>', ':m-2<CR>')
utils.map('n', '<m-down>', ':m+<CR>')
utils.map('n', '<m-up>', ':m-2<CR>')

-- remap jump keys
utils.map('n', '<C-j>', '<C-i>')
utils.map('n', '<C-k>', '<C-o>')

-- GitSign keymap
utils.map('n', ']c', "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'", { noremap = true, expr = true })
utils.map('n', '[c', "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'", { noremap = true, expr = true })

utils.map('n', '<leader>hs', '<cmd>lua require"gitsigns".stage_hunk()<CR>')
utils.map('v', '<leader>hs', '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>')
utils.map('n', '<leader>hu', '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>')
utils.map('n', '<leader>hr', '<cmd>lua require"gitsigns".reset_hunk()<CR>')
utils.map('v', '<leader>hr', '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>')
utils.map('n', '<leader>hR', '<cmd>lua require"gitsigns".reset_buffer()<CR>')
utils.map('n', '<leader>hp', '<cmd>lua require"gitsigns".preview_hunk()<CR>')
utils.map('n', '<leader>hb', '<cmd>lua require"gitsigns".blame_line{full=true}<CR>')
utils.map('n', '<leader>hS', '<cmd>lua require"gitsigns".stage_buffer()<CR>')
utils.map('n', '<leader>hU', '<cmd>lua require"gitsigns".reset_buffer_index()<CR>')
utils.map('o', 'ih', ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>')
utils.map('x', 'ih', ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>')

-- Telescope keymap
utils.map('n', 'gw', "<cmd>lua require('telescope.builtin').grep_string()<CR>", silent_noremap)
utils.map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').live_grep()<CR>", silent_noremap)
utils.map('n', '<leader>fb', "<cmd>lua require('telescope').extensions.file_browser.file_browser({path =  vim.fn.expand('%:p:h')})<CR>", silent_noremap)
utils.map('n', '<leader>\\', "<cmd>Telescope buffers<CR>", silent_noremap)
utils.map('n', '<leader>;', "<cmd>Telescope help_tags<CR>", silent_noremap)

-- Todo comments keymap
utils.map('n', '<leader>c', "<cmd>TodoTelescope<CR>", silent_noremap)

-- Zen mode keymap
utils.map('n', '<leader>z', "<cmd>ZenMode<CR>", silent_noremap)

-- Terminal & ToggleTerm keymap
--  toggleterm keymap, set in `toggleterm-conf` file. Currently used : <leader>t
utils.map('n', '<leader>g', "<cmd>lua _LAZYGIT_TOGGLE()<CR>", silent_noremap)
utils.map('n', '<leader>M', "<cmd>lua _GOTOP_TOGGLE()<CR>", silent_noremap)
-- utils.map('n', '<leader>s', "<cmd>lua _SPOTIFY_TOGGLE()<CR>", silent_noremap)

-- function _G.set_terminal_keymaps()
--   utils.map('t', '<C-q>', [[<C-\><C-n>]])
--   utils.map('t', '<C-h>', [[<C-\><C-n><C-W>h]])
--   utils.map('t', '<C-j>', [[<C-\><C-n><C-W>j]])
--   utils.map('t', '<C-k>', [[<C-\><C-n><C-W>k]])
--   utils.map('t', '<C-l>', [[<C-\><C-n><C-W>l]])
-- end
-- vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

-- Glow keymap (markdown preview)
utils.map('n', '<leader>m', "<cmd>Glow<CR>", silent_noremap)

