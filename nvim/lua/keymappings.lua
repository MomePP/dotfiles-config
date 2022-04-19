local remap = { noremap = false }
local silent = { silent = true }
local expr = { expr = true }

local keymaps = { }

vim.keymap.set('n', '<C-l>', ':nohl<CR>')      -- clear highlight
vim.keymap.set('n', 'dw', 'vb"_d')             -- delete a word backward
vim.keymap.set('n', '<leader>d', '"_d')        -- delete without yank
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('v', 'p', '"_dP')               -- replace-paste without yank
vim.keymap.set('i', '<S-Tab>', '<C-d>')        -- de-tab while in insert mode
vim.keymap.set('n', 'Y', 'y$')                 -- Yank line after cursor
vim.keymap.set('n', 'P', '<cmd>pu<cr>', remap) -- Paste on new line

-- INFO: map shift scroll wheel to scroll horizontal
vim.keymap.set('', '<S-ScrollWheelUp>', 'zh')
vim.keymap.set('', '<S-2-ScrollWheelUp>', '2zh')
vim.keymap.set('', '<S-3-ScrollWheelUp>', '3zh')
vim.keymap.set('', '<S-4-ScrollWheelUp>', '4zh')
vim.keymap.set('', '<S-ScrollWheelDown>', 'zl')
vim.keymap.set('', '<S-2-ScrollWheelDown>', '2zl')
vim.keymap.set('', '<S-3-ScrollWheelDown>', '3zl')
vim.keymap.set('', '<S-4-ScrollWheelDown>', '4zl')

-- INFO: Keeping cursor centered
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', 'J', 'mzJ`z')

-- INFO: add undo break points
vim.keymap.set('i', ',', ',<C-g>u')
vim.keymap.set('i', '.', '.<C-g>u')
vim.keymap.set('i', '!', '!<C-g>u')
vim.keymap.set('i', '?', '?<C-g>u')

-- INFO: Jumplist mutation
-- vim.keymap.set('n', 'k', '(v:count > 5 ? "m\'" . v:count : "") . "k"', expr)
-- vim.keymap.set('n', 'j', '(v:count > 5 ? "m\'" . v:count : "") . "j"', expr)

-- INFO: Bufferline config
vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', silent)
vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', silent)
vim.keymap.set('n', 't]', ':BufferLineMoveNext<CR>', silent)
vim.keymap.set('n', 't[', ':BufferLineMovePrev<CR>', silent)
vim.keymap.set('n', 'tp', ':BufferLinePick<CR>', silent)
vim.keymap.set('n', 'tq', ':Bdelete<CR>', silent)

-- INFO: Panes config using `focus` plugin
vim.keymap.set('n', '<Space>', ':FocusSplitCycle<CR>')
vim.keymap.set('n', 'sm', ':FocusMaxOrEqual<CR>')
vim.keymap.set('n', 'sn', ':FocusSplitNicely<CR>')
vim.keymap.set('n', 'sq', '<C-w>q')

vim.keymap.set('n', 's<left>', ':FocusSplitLeft<CR>')
vim.keymap.set('n', 's<right>', ':FocusSplitRight<CR>')
vim.keymap.set('n', 's<up>', ':FocusSplitUp<CR>')
vim.keymap.set('n', 's<down>', ':FocusSplitDown<CR>')

vim.keymap.set('n', 'sh', ':FocusSplitLeft<CR>')
vim.keymap.set('n', 'sl', ':FocusSplitRight<CR>')
vim.keymap.set('n', 'sk', ':FocusSplitUp<CR>')
vim.keymap.set('n', 'sj', ':FocusSplitDown<CR>')

-- INFO: resize window
vim.keymap.set('n', '<C-w><left>', '<C-w><')
vim.keymap.set('n', '<C-w><right>', '<C-w>>')
vim.keymap.set('n', '<C-w><up>', '<C-w>+')
vim.keymap.set('n', '<C-w><down>', '<C-w>-')

-- INFO: move line or visually selected block - opt+j/k - must set iterm to esc+
vim.keymap.set('i', '<m-j>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<m-k>', '<Esc>:m .-2<CR>==gi')
vim.keymap.set('i', '<m-down>', '<Esc>:m .+1<CR>==gi')
vim.keymap.set('i', '<m-up>', '<Esc>:m .-2<CR>==gi')

vim.keymap.set('v', '<m-k>', ':m \'<-2<CR>gv=gv')
vim.keymap.set('v', '<m-j>', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', '<m-down>', ':m \'>+1<CR>gv=gv')
vim.keymap.set('v', '<m-up>', ':m \'<-2<CR>gv=gv')

vim.keymap.set('n', '<m-j>', ':m+<CR>')
vim.keymap.set('n', '<m-k>', ':m-2<CR>')
vim.keymap.set('n', '<m-down>', ':m+<CR>')
vim.keymap.set('n', '<m-up>', ':m-2<CR>')

-- INFO: remap jump keys
vim.keymap.set('n', '<C-j>', '<C-i>', silent)
vim.keymap.set('n', '<C-k>', '<C-o>', silent)

-- INFO: GitSign keymap
vim.keymap.set('n', ']c', function() if vim.wo.diff then return ']c' end vim.schedule(function() require 'gitsigns.actions'.next_hunk() end) return '<Ignore>' end, expr)
vim.keymap.set('n', '[c', function() if vim.wo.diff then return '[c' end vim.schedule(function() require 'gitsigns.actions'.prev_hunk() end) return '<Ignore>' end, expr)

vim.keymap.set({'n', 'v'}, '<leader>hs', ':GitSigns stage_hunk<CR>')
vim.keymap.set({'n', 'v'}, '<leader>hr', ':GitSigns reset_hunk<CR>')
vim.keymap.set('n', '<leader>hu', ':GitSigns undo_stage_hunk()<CR>')
vim.keymap.set('n', '<leader>hR', ':GitSigns reset_buffer()<CR>')
vim.keymap.set('n', '<leader>hp', ':GitSigns preview_hunk()<CR>')
vim.keymap.set('n', '<leader>hb', ':GitSigns blame_line<CR>')
vim.keymap.set('n', '<leader>hS', ':GitSigns stage_buffer()<CR>')
vim.keymap.set('n', '<leader>hU', ':GitSigns reset_buffer_index()<CR>')
vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>GitSigns select_hunk<CR>')

-- INFO: Telescope keymap
vim.keymap.set('n', 'gw', ":Telescope grep_string<CR>", silent)
vim.keymap.set('n', '<leader>\\', ":Telescope buffers<CR>", silent)
vim.keymap.set('n', '<leader>;', ":Telescope help_tags<CR>", silent)
vim.keymap.set('n', '<leader>j', ":Telescope jumplist<CR>", silent)
vim.keymap.set('n', '<leader>/', ":Telescope current_buffer_fuzzy_find<CR>", silent)
vim.keymap.set('n', '<leader>fs', ":Telescope live_grep<CR>", silent)
vim.keymap.set('n', '<leader>fb', function() require('telescope').extensions.file_browser.file_browser({path = vim.fn.expand('%:p:h')}) end, silent)

-- INFO: Todo comments keymap
vim.keymap.set('n', '<leader>c', ":TodoTelescope<CR>", silent)

-- INFO: Zen mode keymap
vim.keymap.set('n', '<leader>z', ":ZenMode<CR>", silent)

-- INFO: Terminal & ToggleTerm keymap
--  toggleterm keymap, set in `toggleterm-conf` file. Currently used : <leader>t
keymaps.toggleterm = {
    toggle = '<leader>t'
}
vim.keymap.set('n', '<leader>g', function() _LAZYGIT_TOGGLE() end, silent)
vim.keymap.set('n', '<leader>P', function() _GOTOP_TOGGLE() end, silent)
-- vim.keymap.set('n', '<leader>s', "<cmd>lua _SPOTIFY_TOGGLE()<CR>", silent_noremap)

-- function _G.set_terminal_keymaps()
--   vim.keymap.set('t', '<C-q>', [[<C-\><C-n>]])
--   vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-W>h]])
--   vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-W>j]])
--   vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-W>k]])
--   vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-W>l]])
-- end
-- vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

-- INFO: Glow keymap (markdown preview)
-- vim.keymap.set('n', '<leader>p', '<cmd>Glow<CR>', silent_noremap)
vim.keymap.set('n', '<leader>p', ':MarkdownPreviewToggle<CR>', silent)

-- INFO: LSP keymap
vim.keymap.set('n', 'gd', ':Telescope lsp_definitions<CR>', silent)
vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>', silent)
vim.keymap.set('n', 'gt', ":Telescope lsp_type_definitions<CR>", silent)
vim.keymap.set('n', 'gx', ":Telescope lsp_code_actions<CR>", silent)
vim.keymap.set('x', 'gx', ":Telescope lsp_range_code_actions<CR>", silent)
vim.keymap.set('n', 'gr', ":Telescope lsp_references<CR>", silent)
vim.keymap.set('n', '<leader>ls', ":Telescope lsp_document_symbols<CR>", silent)
vim.keymap.set('n', '<leader>ld', ":Telescope diagnostics<CR>", silent)
vim.keymap.set('n', ']d', function() vim.diagnostic.goto_next({ border = 'rounded'}) end, silent)
vim.keymap.set('n', '[d', function() vim.diagnostic.goto_prev({ border = 'rounded'}) end, silent)
vim.keymap.set('n', 'gh', function() vim.diagnostic.open_float({ border = 'rounded' }) end, silent)
vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, silent)
vim.keymap.set('n', 'gp', vim.lsp.buf.hover, silent)
vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, silent)
vim.keymap.set('n', '<leader>ff', vim.lsp.buf.formatting, silent)

-- INFO: Marks keymap
vim.keymap.set('n', "'", function() require'marks'.next() end, silent)
vim.keymap.set('n', '"', function() require'marks'.prev() end, silent)
vim.keymap.set('n', "m'", function() require'marks'.toggle() end, silent)
vim.keymap.set('n', 'm"', function() require'marks'.preview() end, silent)
vim.keymap.set('n', 'md', function() require'marks'.delete_buf() end, silent)

-- using telescope to show all marks list
vim.keymap.set('n', '<leader>m', function()
    require'plugins-config.telescope'.marks_picker({
        layout_strategy = 'horizontal',
        layout_config = { preview_width = 0.65 },
    }) end, silent)

-- INFO: autopair keymap
keymaps.autopair = {
    wrap = '<C-e>'
}

-- INFO: hlslens keymap
vim.keymap.set('n', 'n', [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', 'N', [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], silent)

return keymaps

