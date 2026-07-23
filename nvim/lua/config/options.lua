local opt          = vim.opt

-- General
opt.syntax         = 'off'
opt.spelloptions   = 'noplainbuffer'

opt.undofile       = true
opt.backup         = false
opt.writebackup    = false
opt.swapfile       = false
opt.updatetime     = 250
opt.timeoutlen     = 400
opt.undolevels     = 5000

opt.title          = true
opt.mouse          = 'a'
opt.mousemodel     = 'extend'
opt.clipboard      = vim.env.SSH_TTY and '' or 'unnamedplus'

opt.sessionoptions = { 'buffers', 'curdir', 'winsize', 'folds' }
opt.wildignore     = '**/node_module/*, **/.pio/*, **/.git/*'

-- UI editor
opt.number         = true
opt.relativenumber = true
opt.ruler          = false

opt.breakindent    = true
opt.linebreak      = true
opt.wrap           = false

opt.showcmd        = false
opt.showmode       = false
opt.splitright     = true

-- opt.foldenable     = false
opt.foldlevelstart = 99
opt.foldcolumn     = '1'
opt.foldtext       = ''

opt.fillchars:append {
    horiz     = '━',
    horizup   = '┻',
    horizdown = '┳',
    vert      = '┃',
    vertleft  = '┫',
    vertright = '┣',
    verthoriz = '╋',
    eob       = ' ',
    fold      = ' ',
    foldclose = '',
    foldopen  = '',
    foldsep   = ' ',
    foldinner = ' '
}

opt.showtabline   = 0
opt.cmdheight     = 0
opt.laststatus    = 3
opt.statusline    = ' '
opt.numberwidth   = 3
opt.signcolumn    = 'yes'
-- opt.statuscolumn  = "%=%{v:virtnum < 1 ? (v:relnum ? v:relnum : v:lnum < 10 ? v:lnum . '  ' : v:lnum) : ''}%=%s"

opt.pumheight     = 10 -- Make popup menu smaller
opt.pumblend      = 8  -- Make builtin completion menus slightly transparent
opt.winblend      = 5  -- Make floating windows slightly transparent

-- Editing
opt.ignorecase    = true -- Ignore case when searching (use `\C` to force not doing that)
opt.incsearch     = true -- Show search results while typing
opt.infercase     = true -- Infer letter cases for a richer built-in keyword completion
opt.smartcase     = true -- Don't ignore case when searching if pattern has upper case
opt.smartindent   = true -- Make indenting smart
opt.shiftround    = true

opt.expandtab     = true
opt.showmatch     = true

opt.shiftwidth    = 4
opt.tabstop       = 4
opt.scrolloff     = 8
opt.sidescrolloff = 8

opt.iskeyword:append { '-' } -- consider string-string as whole word
opt.formatoptions = 'jrqln1' -- see :h fo-table
opt.shortmess     = 'fnxoOtTF'
opt.jumpoptions   = 'stack'
