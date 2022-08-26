vim.opt.syntax = 'on'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.title = true
vim.opt.backup = false
vim.opt.showcmd = false
vim.opt.ruler = false
vim.opt.showmatch = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = false
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
vim.opt.completeopt:append('menuone,noselect')
vim.opt.wildignore = '**/node_module/*, **/.pio/*, **/.git/*'
vim.opt.formatoptions:append('r')
vim.opt.swapfile = false
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.fillchars:append({
    horiz = '━',
    horizup = '┻',
    horizdown = '┳',
    vert = '┃',
    vertleft = '┫',
    vertright = '┣',
    verthoriz = '╋',
})

-- INFO: winbar configuration
-- vim.o.winbar = '%{%v:lua.require("winbar").statusline()%}'

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

vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'highlight text on yank',
    pattern = '*',
    callback = function() vim.highlight.on_yank({ on_visual = false }) end
})

-- check if we need to reload file when it changed
vim.api.nvim_create_autocmd('FocusGained', {
    command = ':checktime'
})

-- disable search highlight when enter terminal mode and re-enable when leave
vim.api.nvim_create_augroup('TermHLSearch', { clear = true })
vim.api.nvim_create_autocmd('TermEnter', {
    desc = 'disable hlsearch when enter terminal mode',
    group = 'TermHLSearch',
    command = ':setlocal nohlsearch'
})
vim.api.nvim_create_autocmd('TermLeave', {
    desc = 'enable hlsearch when leave terminal mode',
    group = 'TermHLSearch',
    command = ':setlocal hlsearch'
})

-- INFO: global lua func for lazygit remoted to open file
function _OpenFile(filePath)
    local exec_cmd = "edit " .. filePath
    vim.defer_fn(function() vim.cmd(exec_cmd) end, 100)
end
