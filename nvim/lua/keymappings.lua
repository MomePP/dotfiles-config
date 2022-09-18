local silent = { silent = true }
local expr = { expr = true }

local keymaps = {}

vim.keymap.set('n', '<C-l>', ':nohl<CR>', silent) -- clear highlight
vim.keymap.set('n', 'dw', 'vb"_d') -- delete a word backward
vim.keymap.set('n', '<leader>d', '"_d') -- delete without yank
vim.keymap.set('n', 'x', '"_x')
vim.keymap.set('v', 'p', '"_dP') -- replace-paste without yank
vim.keymap.set('i', '<S-Tab>', '<C-d>') -- de-tab while in insert mode
vim.keymap.set('n', 'Y', 'y$') -- Yank line after cursor
vim.keymap.set('n', 'P', '<cmd>pu<CR>') -- Paste on new line

-- INFO: command-line abbreviations
vim.keymap.set('c', 'W', 'w')
vim.keymap.set('c', 'W!', 'w!')
vim.keymap.set('c', 'Wq', 'wq')
vim.keymap.set('c', 'WQ', 'wq')
vim.keymap.set('c', 'Wa', 'wa')
vim.keymap.set('c', 'Q', 'q')
vim.keymap.set('c', 'Q!', 'q!')
vim.keymap.set('c', 'Qa', 'qa')
vim.keymap.set('c', 'QA', 'qa')

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

-- INFO: Buffers navigated keys
vim.keymap.set('n', 'tq', ':Bdelete<CR>', silent)
vim.keymap.set('n', '<Tab>', ':bnext<CR>', silent)
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', silent)

-- INFO: Panes config using `focus` plugin
vim.keymap.set('n', '<space>', function() require('focus').split_cycle() end, silent)
vim.keymap.set('n', '<leader><space>', function() require('focus').focus_toggle() end, silent)
vim.keymap.set('n', 'wt', function() require('focus').focus_max_or_equal() end, silent)
vim.keymap.set('n', 'wh', function() require('focus').split_command('h') end, silent)
vim.keymap.set('n', 'wl', function() require('focus').split_command('l') end, silent)
vim.keymap.set('n', 'wk', function() require('focus').split_command('k') end, silent)
vim.keymap.set('n', 'wj', function() require('focus').split_command('j') end, silent)
vim.keymap.set('n', 'wq', '<C-w>q', silent)

-- INFO: resize window
vim.keymap.set('n', '<C-w><left>', '<C-w><')
vim.keymap.set('n', '<C-w><right>', '<C-w>>')
vim.keymap.set('n', '<C-w><up>', '<C-w>+')
vim.keymap.set('n', '<C-w><down>', '<C-w>-')

-- INFO: move line or visually selected block - opt+j/k - must set iterm to esc+
vim.keymap.set('i', '<m-j>', '<Esc>:m .+1<CR>==gi', silent)
vim.keymap.set('i', '<m-k>', '<Esc>:m .-2<CR>==gi', silent)
vim.keymap.set('i', '<m-down>', '<Esc>:m .+1<CR>==gi', silent)
vim.keymap.set('i', '<m-up>', '<Esc>:m .-2<CR>==gi', silent)

vim.keymap.set('v', '<m-k>', ':m \'<-2<CR>gv=gv', silent)
vim.keymap.set('v', '<m-j>', ':m \'>+1<CR>gv=gv', silent)
vim.keymap.set('v', '<m-down>', ':m \'>+1<CR>gv=gv', silent)
vim.keymap.set('v', '<m-up>', ':m \'<-2<CR>gv=gv', silent)

vim.keymap.set('n', '<m-j>', ':m+<CR>', silent)
vim.keymap.set('n', '<m-k>', ':m-2<CR>', silent)
vim.keymap.set('n', '<m-down>', ':m+<CR>', silent)
vim.keymap.set('n', '<m-up>', ':m-2<CR>', silent)

-- INFO: remap jump keys
vim.keymap.set('n', '<C-j>', '<C-i>', silent)
vim.keymap.set('n', '<C-k>', '<C-o>', silent)

-- INFO: GitSign keymap
vim.keymap.set('n', ']c', function() if vim.wo.diff then return ']c' end vim.schedule(function() require 'gitsigns.actions'.next_hunk() end) return '<Ignore>' end , expr)
vim.keymap.set('n', '[c', function() if vim.wo.diff then return '[c' end vim.schedule(function() require 'gitsigns.actions'.prev_hunk() end) return '<Ignore>' end , expr)
vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hu', ':Gitsigns undo_stage_hunk<CR>', silent)
vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hp', ':Gitsigns preview_hunk<CR>', silent)
vim.keymap.set('n', '<leader>hb', ':Gitsigns blame_line<CR>', silent)

-- INFO: Telescope keymap
vim.keymap.set('n', 'gw', require 'telescope.builtin'.grep_string, silent)
vim.keymap.set('n', '<leader>\\', require 'telescope.builtin'.buffers, silent)
vim.keymap.set('n', '<leader>;', require 'telescope.builtin'.help_tags, silent)
vim.keymap.set('n', '<leader>j', require 'telescope.builtin'.jumplist, silent)
vim.keymap.set('n', '<leader>/', require 'telescope.builtin'.current_buffer_fuzzy_find, silent)
vim.keymap.set('n', '<leader>?', require 'telescope.builtin'.oldfiles, silent)
vim.keymap.set('n', '<leader>fs', require 'telescope.builtin'.live_grep, silent)
vim.keymap.set('n', '<leader>fb', require 'telescope'.extensions.file_browser.file_browser, silent)

-- INFO: Todo comments keymap
vim.keymap.set('n', '<leader>c', ":TodoTelescope<CR>", silent)

-- INFO: Terminal & ToggleTerm keymap
--  toggleterm keymap, set in `toggleterm-conf` file. Currently used : <leader>t
keymaps.toggleterm = {
    toggle = '<leader>t'
}
vim.keymap.set('n', '<leader>g', function() _LAZYGIT_TOGGLE() end, silent)
vim.keymap.set('n', '<leader>P', function() _GOTOP_TOGGLE() end, silent)

-- INFO: markdown preview keymap
vim.keymap.set('n', '<leader>p', ':MarkdownPreviewToggle<CR>', silent)

-- INFO: LSP keymap
keymaps.lsp = {
    ['gd'] = function() require 'telescope.builtin'.lsp_definitions() end,
    ['gD'] = function() vim.lsp.buf.declaration() end,
    ['gi'] = function() require 'telescope.builtin'.lsp_implementations() end,
    ['gt'] = function() require 'telescope.builtin'.lsp_type_definitions() end,
    ['gr'] = function() require 'telescope.builtin'.lsp_references() end,
    ['gx'] = function() vim.lsp.buf.code_action() end,
    ['gs'] = function() vim.lsp.buf.signature_help() end,
    ['gp'] = function() vim.lsp.buf.hover() end,
    ['K'] = function() vim.lsp.buf.hover() end,
    ['gl'] = function() vim.diagnostic.open_float() end,
    [']d'] = function() vim.diagnostic.goto_next({ float = false }) end,
    ['[d'] = function() vim.diagnostic.goto_prev({ float = false }) end,
    ['<leader>ls'] = function() require 'telescope.builtin'.lsp_document_symbols() end,
    ['<leader>ld'] = function() require 'telescope.builtin'.diagnostics() end,
    ['<leader>lr'] = function() vim.lsp.buf.rename() end,
    ['<leader>ff'] = function() vim.lsp.buf.format({ async = true }) end,
}

-- INFO: Marks keymap
vim.keymap.set('n', "'", function() require 'marks'.next() end, silent)
vim.keymap.set('n', '"', function() require 'marks'.prev() end, silent)
vim.keymap.set('n', "m'", function() require 'marks'.toggle() end, silent)
vim.keymap.set('n', 'm"', function() require 'marks'.preview() end, silent)
vim.keymap.set('n', 'md', function() require 'marks'.delete_buf() end, silent)

-- using telescope to show all marks list
vim.keymap.set('n', '<leader>m', function()
    require('plugins-config.telescope-config').marks_picker({
        layout_strategy = 'horizontal',
        layout_config = { preview_width = 0.65 },
    })
end, silent)

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

-- INFO: session-manager keymaps
vim.keymap.set('n', '<leader>sr', ':SessionManager load_session<CR>', silent)
vim.keymap.set('n', '<leader>ss', ':SessionManager save_current_session<CR>', silent)
vim.keymap.set('n', '<leader>sd', ':SessionManager delete_session<CR>', silent)

return keymaps
