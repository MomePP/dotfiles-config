local opt = vim.opt

-- General
opt.syntax       = 'on'
opt.spelloptions = 'noplainbuffer'

opt.undofile    = true
opt.backup      = false
opt.writebackup = false
opt.swapfile    = false
opt.updatetime  = 200 -- Save swap file and trigger CursorHold

opt.title     = true
opt.mouse     = 'a'
opt.shell     = 'fish'
opt.clipboard = 'unnamedplus'

opt.sessionoptions = { 'buffers', 'curdir', 'winsize' }
opt.wildignore     = '**/node_module/*, **/.pio/*, **/.git/*'

-- UI editor
opt.termguicolors  = true
opt.number         = true
opt.relativenumber = true
opt.ruler          = false

opt.linebreak = true
opt.wrap      = false

opt.showcmd  = false
opt.showmode = false

opt.foldlevel      = 99
opt.foldlevelstart = 99
opt.foldenable     = true
-- opt.foldcolumn     = '1'

opt.signcolumn = 'yes'
opt.fillchars:append {
    horiz     = '━',
    horizup   = '┻',
    horizdown = '┳',
    vert      = '┃',
    vertleft  = '┫',
    vertright = '┣',
    verthoriz = '╋',
    foldopen  = '',
    foldclose = '',
    eob       = ' ',
}

opt.showtabline  = 0
opt.cmdheight    = 0
opt.laststatus   = 3
opt.numberwidth  = 3
opt.statuscolumn = "%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : ''}%=%s"

opt.pumheight = 10 -- Make popup menu smaller
-- opt.pumblend  = 8 -- Make builtin completion menus slightly transparent
-- opt.winblend  = 8 -- Make floating windows slightly transparent

-- Editing
opt.ignorecase  = true -- Ignore case when searching (use `\C` to force not doing that)
opt.incsearch   = true -- Show search results while typing
opt.infercase   = true -- Infer letter cases for a richer built-in keyword completion
opt.smartcase   = true -- Don't ignore case when searching if pattern has upper case
opt.smartindent = true -- Make indenting smart

opt.expandtab = true
opt.showmatch = true

opt.shiftwidth    = 4
opt.tabstop       = 4
opt.scrolloff     = 8
opt.sidescrolloff = 8

opt.grepprg    = 'rg --vimgrep'
opt.grepformat = '%f:%l:%c:%m'

opt.iskeyword:append { '-' } -- consider string-string as whole word
opt.completeopt   = { 'menuone', 'noinsert', 'noselect' }
opt.wildmode      = 'list:longest'
opt.formatoptions = 'jrqln1' -- see :h fo-table
opt.shortmess     = 'fnxoOtTF'
