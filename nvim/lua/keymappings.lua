local utils = require('utils')
local remap = { noremap = false }
local silent_noremap = { noremap = true, silent = true }

local keymaps = { }

utils.map('n', '<C-l>', '<cmd>nohl<cr>')  -- clear highlight
utils.map('n', 'dw', 'vb"_d')             -- delete a word backward
utils.map('n', '<leader>d', '"_d')        -- delete without yank
utils.map('n', 'x', '"_x')
utils.map('v', 'p', '"_dP')               -- replace-paste without yank
utils.map('i', '<S-Tab>', '<C-d>')        -- de-tab while in insert mode
utils.map('n', 'Y', 'y$')                 -- Yank line after cursor
utils.map('n', 'P', '<cmd>pu<cr>', remap) -- Paste on new line

-- INFO: map shift scroll wheel to scroll horizontal
utils.map('', '<S-ScrollWheelUp>', 'zh')
utils.map('', '<S-2-ScrollWheelUp>', '2zh')
utils.map('', '<S-3-ScrollWheelUp>', '3zh')
utils.map('', '<S-4-ScrollWheelUp>', '4zh')
utils.map('', '<S-ScrollWheelDown>', 'zl')
utils.map('', '<S-2-ScrollWheelDown>', '2zl')
utils.map('', '<S-3-ScrollWheelDown>', '3zl')
utils.map('', '<S-4-ScrollWheelDown>', '4zl')

-- INFO: Keeping cursor centered
utils.map('n', 'n', 'nzzzv')
utils.map('n', 'N', 'Nzzzv')
utils.map('n', 'J', 'mzJ`z')

-- INFO: add undo break points
utils.map('i', ',', ',<C-g>u')
utils.map('i', '.', '.<C-g>u')
utils.map('i', '!', '!<C-g>u')
utils.map('i', '?', '?<C-g>u')

-- INFO: Jumplist mutation
-- utils.map('n', 'k', '(v:count > 5 ? "m\'" . v:count : "") . "k"', { noremap = true, expr = true })
-- utils.map('n', 'j', '(v:count > 5 ? "m\'" . v:count : "") . "j"', { noremap = true, expr = true })

-- INFO: Bufferline config
utils.map('n', '<Tab>', ':BufferLineCycleNext<CR>', silent_noremap)
utils.map('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', silent_noremap)
utils.map('n', 'tp', ':BufferLinePick<CR>', silent_noremap)
utils.map('n', 'tq', ':Bdelete<CR>', silent_noremap)

-- INFO: Panes config using `focus` plugin
utils.map('n', '<Space>', ':FocusSplitCycle<CR>')
utils.map('n', 'sm', ':FocusMaxOrEqual<CR>')
utils.map('n', 'sn', ':FocusSplitNicely<CR>')
utils.map('n', 'sq', '<C-w>q')

utils.map('n', 's<left>', ':FocusSplitLeft<CR>')
utils.map('n', 's<right>', ':FocusSplitRight<CR>')
utils.map('n', 's<up>', ':FocusSplitUp<CR>')
utils.map('n', 's<down>', ':FocusSplitDown<CR>')

utils.map('n', 'sh', ':FocusSplitLeft<CR>')
utils.map('n', 'sl', ':FocusSplitRight<CR>')
utils.map('n', 'sk', ':FocusSplitUp<CR>')
utils.map('n', 'sj', ':FocusSplitDown<CR>')

-- INFO: resize window
utils.map('n', '<C-w><left>', '<C-w><')
utils.map('n', '<C-w><right>', '<C-w>>')
utils.map('n', '<C-w><up>', '<C-w>+')
utils.map('n', '<C-w><down>', '<C-w>-')

-- INFO: move line or visually selected block - opt+j/k - must set iterm to esc+
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

-- INFO: remap jump keys
utils.map('n', '<C-j>', '<C-i>', silent_noremap)
utils.map('n', '<C-k>', '<C-o>', silent_noremap)

-- INFO: GitSign keymap
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

-- INFO: Telescope keymap
utils.map('n', 'gw', "<cmd>Telescope grep_string<CR>", silent_noremap)
utils.map('n', '<leader>fs', "<cmd>Telescope live_grep<CR>", silent_noremap)
utils.map('n', '<leader>fb', "<cmd>lua require('telescope').extensions.file_browser.file_browser({path =  vim.fn.expand('%:p:h')})<CR>", silent_noremap)
utils.map('n', '<leader>\\', "<cmd>Telescope buffers<CR>", silent_noremap)
utils.map('n', '<leader>;', "<cmd>Telescope help_tags<CR>", silent_noremap)
utils.map('n', '<leader>j', "<cmd>Telescope jumplist<CR>", silent_noremap)
utils.map('n', '<leader>/', "<cmd>Telescope current_buffer_fuzzy_find<CR>", silent_noremap)

-- INFO: Todo comments keymap
utils.map('n', '<leader>c', "<cmd>TodoTelescope<CR>", silent_noremap)

-- INFO: Zen mode keymap
utils.map('n', '<leader>z', "<cmd>ZenMode<CR>", silent_noremap)

-- INFO: Terminal & ToggleTerm keymap
--  toggleterm keymap, set in `toggleterm-conf` file. Currently used : <leader>t
keymaps.toggleterm = {
    toggle = '<leader>t'
}
utils.map('n', '<leader>g', "<cmd>lua _LAZYGIT_TOGGLE()<CR>", silent_noremap)
utils.map('n', '<leader>P', "<cmd>lua _GOTOP_TOGGLE()<CR>", silent_noremap)
-- utils.map('n', '<leader>s', "<cmd>lua _SPOTIFY_TOGGLE()<CR>", silent_noremap)

-- function _G.set_terminal_keymaps()
--   utils.map('t', '<C-q>', [[<C-\><C-n>]])
--   utils.map('t', '<C-h>', [[<C-\><C-n><C-W>h]])
--   utils.map('t', '<C-j>', [[<C-\><C-n><C-W>j]])
--   utils.map('t', '<C-k>', [[<C-\><C-n><C-W>k]])
--   utils.map('t', '<C-l>', [[<C-\><C-n><C-W>l]])
-- end
-- vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

-- INFO: Glow keymap (markdown preview)
-- utils.map('n', '<leader>p', '<cmd>Glow<CR>', silent_noremap)
utils.map('n', '<leader>p', ':MarkdownPreviewToggle<CR>', silent_noremap)

-- INFO: LSP keymap
utils.map('n', 'gd', '<cmd>Telescope lsp_definitions<CR>', silent_noremap)
utils.map('n', 'gi', '<cmd>Telescope lsp_implementations<CR>', silent_noremap)
utils.map('n', 'gt', "<cmd>Telescope lsp_type_definitions<CR>", silent_noremap)
utils.map('n', 'gx', "<cmd>Telescope lsp_code_actions<CR>", silent_noremap)
utils.map('x', 'gx', "<cmd>Telescope lsp_range_code_actions<CR>", silent_noremap)
utils.map('n', 'gr', "<cmd>Telescope lsp_references<CR>", silent_noremap)
utils.map('n', '<leader>ls', "<cmd>Telescope lsp_document_symbols<CR>", silent_noremap)
utils.map('n', '<leader>ld', "<cmd>Telescope diagnostics<CR>", silent_noremap)
utils.map('n', ']d', "<cmd>lua vim.diagnostic.goto_next({ border = 'rounded'})<CR>", silent_noremap)
utils.map('n', '[d', "<cmd>lua vim.diagnostic.goto_prev({ border = 'rounded'})<CR>", silent_noremap)
utils.map('n', 'gh', "<cmd>lua vim.diagnostic.open_float({ border = 'rounded' })<CR>", silent_noremap)
utils.map('n', 'gs', "<cmd>lua vim.lsp.buf.signature_help()<CR>", silent_noremap)
utils.map('n', 'gp', "<cmd>lua vim.lsp.buf.hover()<CR>", silent_noremap)
utils.map('n', '<leader>lr', "<cmd>lua vim.lsp.buf.rename()<CR>", silent_noremap)
utils.map('n', '<leader>ff', '<cmd>lua vim.lsp.buf.formatting()<CR>', silent_noremap)

-- INFO: Marks keymap
utils.map('n', ']m', "<cmd>lua require'marks'.next()<CR>", silent_noremap)
utils.map('n', '[m', "<cmd>lua require'marks'.prev()<CR>", silent_noremap)
utils.map('n', 'm;', "<cmd>lua require'marks'.toggle()<CR>", silent_noremap)
utils.map('n', 'm:', "<cmd>lua require'marks'.preview()<CR>", silent_noremap)
utils.map('n', 'md', "<cmd>lua require'marks'.delete_buf()<CR>", silent_noremap)

-- using telescope to show all marks list
utils.map('n', '<leader>m', "<cmd>lua require'plugins-config.telescope'.marks_picker({ layout_strategy = 'horizontal', layout_config = { preview_width = 0.65 }, })<CR>", silent_noremap)

-- INFO: autopair keymap
keymaps.autopair = {
    wrap = '<m-b>'
}

return keymaps

