local utils = require('utils')

local cmd = vim.cmd
local indent_size = 4

cmd 'syntax enable'
cmd 'filetype plugin indent on'
utils.opt('w', 'number', true)
utils.opt('w', 'relativenumber', true)
utils.opt('o', 'title', true)
utils.opt('o', 'backup', false)
utils.opt('o', 'showcmd', false)
utils.opt('o', 'ruler', false)
utils.opt('o', 'showmatch', true)
utils.opt('b', 'expandtab', true)
utils.opt('b', 'shiftwidth', indent_size)
utils.opt('b', 'autoindent', true)
utils.opt('b', 'smartindent', true)
utils.opt('b', 'tabstop', indent_size)
utils.opt('o', 'hidden', true)
utils.opt('o', 'ignorecase', true)
utils.opt('o', 'scrolloff', 8)
utils.opt('o', 'sidescrolloff', 8)
utils.opt('o', 'shiftround', true)
utils.opt('o', 'smartcase', true)
utils.opt('o', 'splitbelow', true)
utils.opt('o', 'splitright', true)
utils.opt('o', 'wildmode', 'list:longest')
utils.opt('o', 'clipboard','unnamed,unnamedplus')
utils.opt('o', 'mouse', 'a')
utils.opt('o', 'shell', 'fish')
utils.opt('o', 'inccommand', 'nosplit')
utils.opt('o', 'lazyredraw', true)
utils.opt('w', 'wrap', false)
utils.opt('w', 'signcolumn', 'yes')

-- set files search recursive sub-folder except following ...
utils.opt('o', 'wildignore', '**/node_module/*, **/.pio/*, **/.git/*')

-- turn off paste mode when leaving insert
cmd 'autocmd InsertLeave * set nopaste'

-- open help in vertical
cmd([[autocmd! FileType help :wincmd L | :vert resize 80]])

-- add asterisks in block comments
utils.opt('b', 'formatoptions', 'r', true)

-- set bg highlights
cmd([[
augroup BgHighlight
autocmd!
autocmd WinEnter * set cul
autocmd WinLeave * set nocul
augroup END
]])

-- Highlight on yank
cmd 'au TextYankPost * lua vim.highlight.on_yank {on_visual = false}'

-- Disable netrw -> use telescope to browse directory at first
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1

-- Command-line abbreviations
-- cnoreabbrev g Git
-- cnoreabbrev gopen GBrowse
cmd([[
cnoreabbrev W! w!
cnoreabbrev Q! q!
cnoreabbrev Qall! qall!
cnoreabbrev Wq wq
cnoreabbrev Wa wa
cnoreabbrev Wq wq
cnoreabbrev WQ wq
cnoreabbrev W w
cnoreabbrev Q q
cnoreabbrev Qall qall
]])
