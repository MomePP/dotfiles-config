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
vim.keymap.set('n', 'P', '<cmd>pu<CR>') -- Paste on new line

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
vim.keymap.set('n', '<Space>', ':FocusSplitCycle<CR>', silent)
vim.keymap.set('n', 'wt', ':FocusMaxOrEqual<CR>', silent)
vim.keymap.set('n', 'wh', ':FocusSplitLeft<CR>', silent)
vim.keymap.set('n', 'wl', ':FocusSplitRight<CR>', silent)
vim.keymap.set('n', 'wk', ':FocusSplitUp<CR>', silent)
vim.keymap.set('n', 'wj', ':FocusSplitDown<CR>', silent)
vim.keymap.set('n', 'wq', '<C-w>q', silent)

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

vim.keymap.set({'n', 'v'}, '<leader>hs', ':Gitsigns stage_hunk<CR>', silent)
vim.keymap.set({'n', 'v'}, '<leader>hr', ':Gitsigns reset_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hu', ':Gitsigns undo_stage_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hR', ':Gitsigns reset_buffer<CR>', silent)
vim.keymap.set('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hb', ':Gitsigns blame_line<CR>', silent)
vim.keymap.set('n', '<leader>hS', ':Gitsigns stage_buffer<CR>', silent)
vim.keymap.set('n', '<leader>hU', ':Gitsigns reset_buffer_index<CR>', silent)
vim.keymap.set({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>', silent)

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

-- INFO: Terminal & ToggleTerm keymap
--  toggleterm keymap, set in `toggleterm-conf` file. Currently used : <leader>t
keymaps.toggleterm = {
    toggle = '<leader>t'
}
vim.keymap.set('n', '<leader>g', function() _LAZYGIT_TOGGLE() end, silent)
vim.keymap.set('n', '<leader>P', function() _GOTOP_TOGGLE() end, silent)
-- vim.keymap.set('n', '<leader>s', function() _SPOTIFY_TOGGLE() end, silent)

-- INFO: markdown preview keymap
vim.keymap.set('n', '<leader>p', ':MarkdownPreviewToggle<CR>', silent)

-- INFO: LSP keymap
keymaps.lsp = {
    gd = 'lua require"telescope.builtin".lsp_definitions()',
    gi = 'lua require"telescope.builtin".lsp_implementations()',
    gt = 'lua require"telescope.builtin".lsp_type_definitions()',
    gr = 'lua require"telescope.builtin".lsp_references()',
    gx = 'lua vim.lsp.buf.code_action()',
    gs = 'lua vim.lsp.buf.signature_help()',
    gp = 'lua vim.lsp.buf.hover()',
    K = 'lua vim.lsp.buf.hover()',
    [']d'] = 'lua vim.diagnostic.goto_next({ border = "rounded" })',
    ['[d'] = 'lua vim.diagnostic.goto_prev({ border = "rounded" })',
    ['<leader>ls'] = 'lua require"telescope.builtin".lsp_document_symbols()',
    ['<leader>ld'] = 'lua require"telescope.builtin".diagnostics()',
    ['<leader>lr'] = 'lua vim.lsp.buf.rename()',
    ['<leader>ff'] = 'lua vim.lsp.bug.formatting()',
}

-- INFO: Marks keymap
vim.keymap.set('n', "'", function() require'marks'.next() end, silent)
vim.keymap.set('n', '"', function() require'marks'.prev() end, silent)
vim.keymap.set('n', "m'", function() require'marks'.toggle() end, silent)
vim.keymap.set('n', 'm"', function() require'marks'.preview() end, silent)
vim.keymap.set('n', 'md', function() require'marks'.delete_buf() end, silent)
-- using telescope to show all marks list
vim.keymap.set('n', '<leader>m', function()
    require('plugins-config.telescope').marks_picker({
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

-- INFO: auto-session keymaps
vim.keymap.set('n', '<leader>sl', ':SearchSession<CR>', silent)
vim.keymap.set('n', '<leader>ss', ':SaveSession<CR>', silent)
vim.keymap.set('n', '<leader>sr', ':RestoreSession<CR>', silent)
vim.keymap.set('n', '<leader>sd', ':DeleteSession<CR>', silent)

return keymaps

