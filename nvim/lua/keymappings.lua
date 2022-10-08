local silent = { noremap = true, silent = true }
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

-- INFO: Buffers navigated keys
vim.keymap.set('n', 'tq', ':Bdelete<CR>', silent)
vim.keymap.set('n', '<Tab>', ':bnext<CR>', silent)
vim.keymap.set('n', '<S-Tab>', ':bprev<CR>', silent)

-- INFO: Panes config using `focus` plugin
vim.keymap.set('n', '<space>', require 'focus'.split_cycle, silent)
vim.keymap.set('n', '<leader><space>', require 'focus'.focus_toggle, silent)
vim.keymap.set('n', 'wt', require 'focus'.focus_max_or_equal, silent)
vim.keymap.set('n', 'wh', function() require 'focus'.split_command('h') end, silent)
vim.keymap.set('n', 'wl', function() require 'focus'.split_command('l') end, silent)
vim.keymap.set('n', 'wk', function() require 'focus'.split_command('k') end, silent)
vim.keymap.set('n', 'wj', function() require 'focus'.split_command('j') end, silent)
vim.keymap.set('n', 'wq', '<C-w>q', silent)

-- INFO: resize window
-- vim.keymap.set('n', '<C-w><left>', '<C-w><')
-- vim.keymap.set('n', '<C-w><right>', '<C-w>>')
-- vim.keymap.set('n', '<C-w><up>', '<C-w>+')
-- vim.keymap.set('n', '<C-w><down>', '<C-w>-')

-- INFO: move line or visually selected block - opt+j/k
vim.keymap.set('n', '<m-j>', ':MoveLine(1)<CR>', silent)
vim.keymap.set('n', '<m-k>', ':MoveLine(-1)<CR>', silent)
vim.keymap.set('n', '<m-down>', ':MoveLine(1)<CR>', silent)
vim.keymap.set('n', '<m-up>', ':MoveLine(-1)<CR>', silent)

vim.keymap.set('v', '<m-j>', ':MoveBlock(1)<CR>', silent)
vim.keymap.set('v', '<m-k>', ':MoveBlock(-1)<CR>', silent)
vim.keymap.set('v', '<m-down>', ':MoveBlock(1)<CR>', silent)
vim.keymap.set('v', '<m-up>', ':MoveBlock(-1)<CR>', silent)

vim.keymap.set('i', '<m-j>', '<Esc>:MoveLine(1)<CR>==gi', silent)
vim.keymap.set('i', '<m-k>', '<Esc>:MoveLine(-1)<CR>==gi', silent)
vim.keymap.set('i', '<m-down>', '<Esc>:MoveLine(1)<CR>==gi', silent)
vim.keymap.set('i', '<m-up>', '<Esc>:MoveLine(-1)<CR>==gi', silent)

-- INFO: remap jump keys
vim.keymap.set('n', '<C-j>', '<C-i>', silent)
vim.keymap.set('n', '<C-k>', '<C-o>', silent)

-- INFO: GitSign keymap
vim.keymap.set('n', ']c', function()
    if vim.wo.diff then return ']c' end
    vim.schedule(function() require 'gitsigns.actions'.next_hunk() end)
    return '<Ignore>'
end, expr)
vim.keymap.set('n', '[c', function()
    if vim.wo.diff then return '[c' end
    vim.schedule(function() require 'gitsigns.actions'.prev_hunk() end)
    return '<Ignore>'
end, expr)
vim.keymap.set({ 'n', 'v' }, '<leader>hr', require 'gitsigns.actions'.reset_hunk, silent)
vim.keymap.set('n', '<leader>hp', require 'gitsigns.actions'.preview_hunk, silent)
vim.keymap.set('n', '<leader>hb', require 'gitsigns.actions'.blame_line, silent)
vim.keymap.set('n', '<leader>hB', require 'gitsigns.actions'.toggle_current_line_blame, silent)

-- INFO: Telescope keymap
vim.keymap.set('n', 'gw', require 'telescope.builtin'.grep_string, silent)
vim.keymap.set('n', '<leader>\\', require 'telescope.builtin'.buffers, silent)
vim.keymap.set('n', '<leader>;', require 'telescope.builtin'.help_tags, silent)
vim.keymap.set('n', '<leader>j', require 'telescope.builtin'.jumplist, silent)
vim.keymap.set('n', '<leader>/', require 'telescope.builtin'.live_grep, silent)
vim.keymap.set('n', '<leader>?', require 'telescope.builtin'.oldfiles, silent)
vim.keymap.set('n', '<leader>fs', require 'telescope.builtin'.current_buffer_fuzzy_find, silent)
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
    ['gd'] = require 'telescope.builtin'.lsp_definitions,
    ['gD'] = vim.lsp.buf.declaration,
    ['gi'] = require 'telescope.builtin'.lsp_implementations,
    ['gt'] = require 'telescope.builtin'.lsp_type_definitions,
    ['gr'] = require 'telescope.builtin'.lsp_references,
    ['gx'] = vim.lsp.buf.code_action,
    ['gs'] = vim.lsp.buf.signature_help,
    ['gp'] = vim.lsp.buf.hover,
    ['K'] = function() local ufo_loaded, ufo = pcall(require, 'ufo')
        if ufo_loaded then if ufo.peekFoldedLinesUnderCursor() then return end end
        vim.lsp.buf.hover()
    end,
    ['gl'] = vim.diagnostic.open_float,
    [']d'] = function() vim.diagnostic.goto_next({ float = false }) end,
    ['[d'] = function() vim.diagnostic.goto_prev({ float = false }) end,
    ['<leader>ls'] = require 'telescope.builtin'.lsp_document_symbols,
    ['<leader>ld'] = require 'telescope.builtin'.diagnostics,
    ['<leader>lr'] = vim.lsp.buf.rename,
    ['<leader>ff'] = function() vim.lsp.buf.format({ async = true }) end,
}

-- INFO: Marks keymap
vim.keymap.set('n', "'", require 'marks'.next, silent)
vim.keymap.set('n', '"', require 'marks'.prev, silent)
vim.keymap.set('n', "m'", require 'marks'.toggle, silent)
vim.keymap.set('n', 'm"', require 'marks'.preview, silent)
vim.keymap.set('n', 'md', require 'marks'.delete_buf, silent)

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

-- INFO: ufo keymap
vim.keymap.set('n', 'zR', require 'ufo'.openAllFolds, silent)
vim.keymap.set('n', 'zM', require 'ufo'.closeAllFolds, silent)
vim.keymap.set('n', 'zr', require 'ufo'.openFoldsExceptKinds, silent)
vim.keymap.set('n', 'zm', require 'ufo'.closeFoldsWith, silent) -- closeAllFolds == closeFoldsWith(0)

-- INFO: hlslens keymap
local function ufoSearchKeys(c)
    local ok, msg = pcall(vim.cmd, 'norm!' .. vim.v.count1 .. c)
    if not ok then
        vim.api.nvim_echo({ { msg:match(':(.*)$'), 'ErrorMsg' } }, false, {})
        return
    end
    require('hlslens').start()
    require('ufo').peekFoldedLinesUnderCursor()
end

vim.keymap.set('n', 'n', function() ufoSearchKeys('n') end, silent)
vim.keymap.set('n', 'N', function() ufoSearchKeys('N') end, silent)
vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], silent)
vim.keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], silent)

-- INFO: session-manager keymaps
vim.keymap.set('n', '<leader>sr', require 'session_manager'.load_session, silent)
vim.keymap.set('n', '<leader>ss', require 'session_manager'.save_current_session, silent)
vim.keymap.set('n', '<leader>sd', require 'session_manager'.delete_session, silent)

return keymaps
