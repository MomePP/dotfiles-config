local cmd = vim.cmd
local indent_size = 4

vim.opt.syntax = 'on'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.backup = false
vim.opt.showcmd = false
vim.opt.ruler = false
vim.opt.showmatch = true
vim.opt.expandtab = true
vim.opt.shiftwidth = indent_size
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = indent_size
vim.opt.hidden = true
vim.opt.ignorecase = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.shiftround = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.wildmode = 'list:longest'
vim.opt.clipboard = 'unnamedplus'
vim.opt.mouse = 'a'
vim.opt.shell = 'fish'
vim.opt.inccommand = 'nosplit'
vim.opt.lazyredraw = true
vim.opt.wrap = false
vim.opt.signcolumn = 'yes'
vim.opt.termguicolors = true
vim.opt.completeopt = 'menu,menuone,noselect'
vim.opt.wildignore = '**/node_module/*, **/.pio/*, **/.git/*'
vim.opt.sessionoptions:append('winpos,terminal')
vim.opt.formatoptions:append('r')
vim.opt.swapfile = false
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.laststatus = 3
vim.opt.showtabline = 2


vim.api.nvim_create_autocmd('InsertLeave', {
    desc = 'turn off paste mode when leaving insert',
    pattern = '*',
    command = 'set nopaste'
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'open help docs in vertical split',
    pattern = 'help',
    command = ':wincmd L | :vert'
})

vim.api.nvim_create_augroup('BgHighlight', { clear = true })
vim.api.nvim_create_autocmd('WinEnter', {
    desc = 'set cursorline bg highlight when enter window',
    group = 'BgHighlight',
    pattern = '*',
    command = 'set cursorline'
})
vim.api.nvim_create_autocmd('WinLeave', {
    desc = 'remove cursorline bg highlight when leave window',
    group = 'BgHighlight',
    pattern = '*',
    command = 'set nocursorline'
})

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'highlight text on yank',
    pattern = '*',
    callback = function () vim.highlight.on_yank({on_visual = false}) end
})

-- check if we need to reload file when it changed
vim.api.nvim_create_autocmd('FocusGained', {
    command = ':checktime'
})


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


-- INFO: global lua func for lazygit remoted to open file
-- function _OpenFile(filePath)
--     local exec_cmd = "edit " .. filePath
--     print(exec_cmd)
--     cmd(exec_cmd)
-- end

