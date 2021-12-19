local utils = require('utils')
local remap = { noremap = false }
local silent_noremap = { noremap = true, silent = true }

utils.map('n', '<C-l>', '<cmd>nohl<cr>')  -- clear highlight
utils.map('n', 'dw', 'vb"_d')             -- delete a word backward
utils.map('n', '<leader>d', '"_d')        -- delete without yank
utils.map('n', 'x', '"_x')
utils.map('v', '<leader>p', '"_dP')       -- replace-paste without yank
utils.map('i', '<S-Tab>', '<C-d>')        -- de-tab while in insert mode
utils.map('n', '<C-a>', 'gg<S-v>G')       -- visual - select all
utils.map('n', 'Y', 'y$')                 -- Yank line after cursor
utils.map('n', 'P', '<cmd>pu<cr>', remap) -- Paste on new line

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

-- Window config
-- split window
utils.map('n', 'ss', '<cmd>split<cr><Space>')
utils.map('n', 'sv', '<cmd>vsplit<cr><Space>')

-- move window
utils.map('n', 'sq', '<C-w>q')
utils.map('n', '<Space>', '<C-w>w')

utils.map('', 's<left>', '<C-w>h')
utils.map('', 's<right>', '<C-w>l')
utils.map('', 's<up>', '<C-w>k')
utils.map('', 's<down>', '<C-w>j')

utils.map('', 'sh', '<C-w>h')
utils.map('', 'sl', '<C-w>l')
utils.map('', 'sk', '<C-w>k')
utils.map('', 'sj', '<C-w>j')

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

-- Tab config
utils.map('n', 'te', '<cmd>tabedit<cr>')
utils.map('n', 'tc', '<cmd>tabclose<cr>')
utils.map('n', '<Tab>', '<cmd>tabnext<cr>')
utils.map('n', '<S-Tab>', '<cmd>tabprev<cr>')

-- Lsp saga keymap
utils.map('n', '<leader>t', ":Lspsaga open_floaterm<CR>", silent_noremap)
utils.map('t', '<leader>t', "<C-\\><C-n>:Lspsaga close_floaterm<CR>", silent_noremap)

-- Telescope keymap
-- utils.map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').find_files()<CR>", silent_noremap)
utils.map('n', 'gw', "<cmd>lua require('telescope.builtin').grep_string()<CR>", silent_noremap)
utils.map('n', '<leader>fs', "<cmd>lua require('telescope.builtin').live_grep()<CR>", silent_noremap)
utils.map('n', '<leader>fb', "<cmd>lua require('telescope').extensions.file_browser.file_browser()<CR>", silent_noremap)
utils.map('n', '<leader>fm', "<cmd>lua require('telescope').extensions.media_files.media_files()<CR>", silent_noremap)
utils.map('n', '<leader>gf', "<cmd>lua require('telescope.builtin').git_files()<CR>", silent_noremap)
utils.map('n', '<leader>gb', "<cmd>lua require('telescope.builtin').git_branches()<CR>", silent_noremap)
utils.map('n', '<leader>gs', "<cmd>lua require('telescope.builtin').git_status()<CR>", silent_noremap)
utils.map('n', '<leader>gS', "<cmd>lua require('telescope.builtin').git_stash()<CR>", silent_noremap)
utils.map('n', '<leader>\\', "<cmd>Telescope buffers<CR>", silent_noremap)
utils.map('n', '<leader>;', "<cmd>Telescope help_tags<CR>", silent_noremap)

-- Zen mode keymap
utils.map('n', '<leader>z', "<cmd>ZenMode<CR>", silent_noremap)

