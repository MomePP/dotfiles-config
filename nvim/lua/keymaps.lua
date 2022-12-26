local silent = { noremap = true, silent = true }
local expr = { expr = true }
local silent_expr = { silent = true, expr = true }

-- NOTE: helper functions
local function open_telescope_qflist(options)
    vim.fn.setqflist({}, ' ', options)
    vim.cmd 'Telescope quickfix'
end

local keymaps = {}

keymaps.setup = function()
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

    -- INFO: keeping cursor centered
    vim.keymap.set('n', 'n', 'nzzzv')
    vim.keymap.set('n', 'N', 'Nzzzv')
    vim.keymap.set('n', 'J', 'mzJ`z')

    -- INFO: add undo break points
    vim.keymap.set('i', ',', ',<C-g>u')
    vim.keymap.set('i', '.', '.<C-g>u')
    vim.keymap.set('i', '!', '!<C-g>u')
    vim.keymap.set('i', '?', '?<C-g>u')

    -- INFO: windows/buffers navigated keys
    vim.keymap.set('n', 'tq', '<Cmd>Bdelete<CR>', silent)
    vim.keymap.set('n', '<Tab>', '<Cmd>bnext<CR>', silent)
    vim.keymap.set('n', '<S-Tab>', '<Cmd>bprev<CR>', silent)
    vim.keymap.set('n', 'wq', '<C-w>q', silent)

    -- INFO: misc. keymap
    vim.keymap.set('n', '<C-l>', '<Cmd>noh<CR>', silent) -- clear highlight
    vim.keymap.set('n', 'dw', 'vb"_d') -- delete a word backward
    vim.keymap.set('n', '<leader>d', '"_d') -- delete without yank
    vim.keymap.set('n', 'x', '"_x')
    vim.keymap.set('v', 'p', '"_dP') -- replace-paste without yank
    vim.keymap.set('i', '<S-Tab>', '<C-d>') -- de-tab while in insert mode
    vim.keymap.set('n', 'Y', 'y$') -- Yank line after cursor
    vim.keymap.set('n', 'P', '<cmd>pu<CR>') -- Paste on new line

    -- INFO: resize window
    -- vim.keymap.set('n', '<C-w><left>', '<C-w><')
    -- vim.keymap.set('n', '<C-w><right>', '<C-w>>')
    -- vim.keymap.set('n', '<C-w><up>', '<C-w>+')
    -- vim.keymap.set('n', '<C-w><down>', '<C-w>-')

    -- INFO: remap jump keys
    vim.keymap.set('n', '<C-j>', '<C-i>', silent)
    vim.keymap.set('n', '<C-k>', '<C-o>', silent)

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
end

-- INFO: LSP keymap
keymaps.lsp = {
    ['gd']         = '<Cmd>Telescope lsp_definitions<CR>',
    ['gt']         = '<Cmd>Telescope lsp_type_definitions<CR>',
    ['gr']         = '<Cmd>Telescope lsp_references<CR>',
    ['<leader>ls'] = '<Cmd>Telescope lsp_document_symbols<CR>',
    ['<leader>ld'] = '<Cmd>Telescope diagnostics<CR>',
    [']d']         = function() vim.diagnostic.goto_next({ float = false }) end,
    ['[d']         = function() vim.diagnostic.goto_prev({ float = false }) end,
    ['gD']         = function() vim.lsp.buf.declaration({ on_list = open_telescope_qflist }) end,
    ['gx']         = vim.lsp.buf.code_action,
    ['gs']         = vim.lsp.buf.signature_help,
    ['gp']         = vim.lsp.buf.hover,
    ['<leader>lr'] = vim.lsp.buf.rename,
    ['<leader>ff'] = function() vim.lsp.buf.format({ async = true }) end,
    ['K']          = function()
        local ufo_loaded, ufo = pcall(require, 'ufo')
        if ufo_loaded then if ufo.peekFoldedLinesUnderCursor() then return end end
        vim.lsp.buf.hover()
    end,
}

-- INFO: Lazy keymap
keymaps.lazy = {
    open = '<leader>p',
    opts = silent
}

-- INFO: Focus keymap
keymaps.focus = {
    toggle_enable = '<leader><space>',
    toggle_size   = 'wt',
    split_cycle   = '<space>',
    split_left    = 'wh',
    split_right   = 'wl',
    split_up      = 'wk',
    split_down    = 'wj',
    opts          = silent
}

-- INFO: GitSign keymap
keymaps.gitsigns = {
    next_hunk    = ']c',
    prev_hunk    = '[c',
    reset_hunk   = '<leader>hr',
    preview_hunk = '<leader>hp',
    blame_line   = '<leader>hb',
    toggle_blame = '<leader>hB',
    opts         = { silent = silent, expr = expr },
}

-- INFO: git-conflict keymap
keymaps.gitconflict = {
    toggle_qflist = '<leader>x',
    opts          = silent,
}

-- INFO: Telescope keymap
keymaps.telescope = {
    grep_workspace   = 'gw',
    search_buffer    = '<leader>/',
    search_workspace = '<leader>fw',
    buffers          = '<leader>\\',
    find_files       = '<leader>fs',
    help             = '<leader>;',
    jumplist         = '<leader>j',
    oldfiles         = '<leader>?',
    file_browse      = '<leader>fb',
    opts             = silent,
}

-- INFO: Todocomments keymap
keymaps.todocomments = {
    toggle    = '<leader>c',
    next_todo = ']t',
    prev_todo = '[t',
    opts      = silent,
}

-- INFO: Terminal & ToggleTerm keymap
keymaps.toggleterm = {
    toggle  = '<leader>t',
    lazygit = '<leader>g',
    -- gotop   = '<leader>P',
    opts    = silent,
}

-- INFO: Marks keymap
keymaps.marks = {
    next    = "'",
    prev    = '"',
    toggle  = "m'",
    preview = 'm"',
    clear   = 'md',
    list    = '<leader>m',
    opts    = silent,
}

-- INFO: ufo keymap
keymaps.ufo = {
    open_all    = 'zR',
    open_except = 'zr',
    close_all   = 'zM',
    close_with  = 'zm',
    opts        = silent,
}

-- INFO: hlslens keymap
keymaps.hlslens = {
    search_next = 'n',
    search_prev = 'N',
    word_next   = '*',
    word_prev   = '#',
    go_next     = 'g*',
    go_prev     = 'g#',
    opts        = silent
}

-- INFO: session-manager keymaps
keymaps.session_manager = {
    load   = '<leader>sr',
    save   = '<leader>ss',
    delete = '<leader>sd',
    opts   = silent,
}

-- INFO: Noice keymaps
keymaps.noice = {
    history          = '<leader>M',
    docs_scroll_up   = '<C-u>',
    docs_scroll_down = '<C-d>',
    opts             = { silent = silent, silent_expr = silent_expr },
}

-- INFO: Leap keymaps
keymaps.leap = {
    search      = 's',
    line_search = 'S',
    opts        = silent,
}

-- INFO: markdown preview keymap
keymaps.markdown_preview = {
    toggle = '<leader>P',
    opts   = silent
}

return keymaps
