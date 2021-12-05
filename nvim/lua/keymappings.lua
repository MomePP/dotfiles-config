local utils = require('utils')
local remap = { noremap = false }

utils.map('n', '<C-l>', '<cmd>nohl<cr>')                  -- clear highlight
utils.map('n', 'dw', 'vb"_d')                             -- delete a word backward
utils.map('n', '<leader>d', '"_d')                        -- delete without yank
utils.map('n', 'x', '"_x')
utils.map('v', '<leader>p', '"_dP')                       -- replace-paste without yank
utils.map('i', '<S-Tab>', '<C-d>')                        -- de-tab while in insert mode
utils.map('n', '<C-a>', 'gg<S-v>G', remap)                -- visual - select all

-- Tab config
utils.map('n', 'te', '<cmd>tabedit', remap)
utils.map('n', '<Tab>', '<cmd>tabnext', remap)
utils.map('n', '<S-Tab>', '<cmd>tabprev', remap)

-- Window config
-- split window
utils.map('n', 'ss', '<cmd>split<Return><C-w>w', remap)
utils.map('n', 'sv', '<cmd>vsplit<Return><C-w>w', remap)

-- move window
utils.map('n', 'sq', '<C-w>q', remap)
utils.map('n', '<Space>', '<C-w>w', remap)

utils.map('', 's<left>', '<C-w>h', remap)
utils.map('', 's<right>', '<C-w>l', remap)
utils.map('', 's<up>', '<C-w>k', remap)
utils.map('', 's<down>', '<C-w>j', remap)

utils.map('', 'sh', '<C-w>h', remap)
utils.map('', 'sl', '<C-w>l', remap)
utils.map('', 'sk', '<C-w>k', remap)
utils.map('', 'sj', '<C-w>j', remap)

-- resize window
utils.map('n', '<C-w><left>', '<C-w><', remap)
utils.map('n', '<C-w><right>', '<C-w>>', remap)
utils.map('n', '<C-w><up>', '<C-w>+', remap)
utils.map('n', '<C-w><down>', '<C-w>-', remap)

-- move line or visually selected block - opt+j/k - must set iterm to esc+
utils.map('i', '<m-j>', '<Esc><cmd>m .+1<CR>==gi')
utils.map('i', '<m-k>', '<Esc><cmd>m .-2<CR>==gi')
utils.map('i', '<m-down>', '<Esc><cmd>m .+1<CR>==gi')
utils.map('i', '<m-up>', '<Esc><cmd>m .-2<CR>==gi')

utils.map('v', '<m-j>', '<cmd>m ">+1<CR>gv=gv')
utils.map('v', '<m-k>', '<cmd>m "<-2<CR>gv=gv')
utils.map('v', '<m-down>', '<cmd>m ">+1<CR>gv=gv')
utils.map('v', '<m-up>', '<cmd>m "<-2<CR>gv=gv')

utils.map('n', '<m-j>', '<cmd>m+<CR>')
utils.map('n', '<m-k>', '<cmd>m-2<CR>')
utils.map('n', '<m-down>', '<cmd>m+<CR>')
utils.map('n', '<m-up>', '<cmd>m-2<CR>')

-- Terminal
-- exit terminal to normal mode
utils.map('t', '<Esc>', '<C-\\><C-n>')

