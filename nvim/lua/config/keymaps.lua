local keymaps = {}

-- NOTE: helper functions
local function open_with_qflist(options)
    vim.fn.setqflist({}, ' ', options)
    vim.cmd 'TroubleToggle quickfix'
end

keymaps.setup = function()
    -- INFO: move up / down by visible lines with no [count]
    vim.keymap.set({ 'n', 'x' }, 'j', [[v:count == 0 ? 'gj' : 'j']], { expr = true, silent = true })
    vim.keymap.set({ 'n', 'x' }, 'k', [[v:count == 0 ? 'gk' : 'k']], { expr = true, silent = true })

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

    -- INFO: add undo break points
    vim.keymap.set('i', ',', ',<C-g>u')
    vim.keymap.set('i', '.', '.<C-g>u')
    vim.keymap.set('i', '!', '!<C-g>u')
    vim.keymap.set('i', '?', '?<C-g>u')

    -- INFO: windows/buffers navigated keys
    -- vim.keymap.set('n', '<Tab>', '<Cmd>bnext<CR>')
    -- vim.keymap.set('n', '<S-Tab>', '<Cmd>bprev<CR>')
    vim.keymap.set('n', 'wq', '<C-w>q')

    -- INFO: misc. keymap
    vim.keymap.set({ 'n', 'i' }, '<Esc>', '<Cmd>noh<CR><Esc>')
    vim.keymap.set({ 'n', 'i' }, '<C-l>', '<Cmd>noh<CR>')
    vim.keymap.set('n', 'dw', 'vb"_d')      -- delete a word backward
    vim.keymap.set('n', '<leader>d', '"_d') -- delete without yank
    vim.keymap.set('n', 'x', '"_x')
    vim.keymap.set('v', 'p', '"_dP')        -- replace-paste without yank
    vim.keymap.set('i', '<S-Tab>', '<C-d>') -- de-tab while in insert mode
    vim.keymap.set('n', 'Y', 'y$')          -- Yank line after cursor
    vim.keymap.set('n', 'P', '<cmd>pu<CR>') -- Paste on new line
    vim.keymap.set('v', '<', '<gv')
    vim.keymap.set('v', '>', '>gv')

    -- INFO: resize window
    -- vim.keymap.set('n', '<C-w><left>', '<C-w><')
    -- vim.keymap.set('n', '<C-w><right>', '<C-w>>')
    -- vim.keymap.set('n', '<C-w><up>', '<C-w>+')
    -- vim.keymap.set('n', '<C-w><down>', '<C-w>-')

    -- INFO: remap jump keys
    vim.keymap.set('n', '<C-j>', '<C-i>')
    vim.keymap.set('n', '<C-k>', '<C-o>')

    -- INFO: quickfix keys
    vim.keymap.set('n', '<leader>q', '<Cmd>TroubleToggle quickfix<CR>')
    vim.keymap.set('n', '<leader>Q', '<Cmd>cexpr []<CR>')
end

-- INFO: LSP keymap
keymaps.lsp = {
    definitions      = { key = 'gd', cmd = '<Cmd>TroubleToggle lsp_definitions<CR>' },
    type_definitions = { key = 'gt', cmd = '<Cmd>TroubleToggle lsp_type_definitions<CR>' },
    reference        = { key = 'gr', cmd = '<Cmd>TroubleToggle lsp_references<CR>' },
    signature_help   = { key = 'gs', cmd = vim.lsp.buf.signature_help },
    rename           = { key = '<leader>lr', cmd = vim.lsp.buf.rename },
    code_action      = { key = '<leader>lx', cmd = vim.lsp.buf.code_action },
    diagnostic       = { key = '<leader>ld', cmd = '<Cmd>TroubleToggle workspace_diagnostics<CR>' },
    diagnostic_next  = { key = ']d', cmd = function() vim.diagnostic.goto_next({ float = false }) end },
    diagnostic_prev  = { key = '[d', cmd = function() vim.diagnostic.goto_prev({ float = false }) end },
    declaration      = { key = 'gD', cmd = function() vim.lsp.buf.declaration({ on_list = open_with_qflist }) end },
    format           = { key = '<leader>ff', cmd = function() vim.lsp.buf.format({ async = true }) end },
    document_symbol  = { key = '<leader>ls', cmd = function() vim.lsp.buf.document_symbol({ on_list = open_with_qflist }) end },
    hover            = {
        key = 'K',
        cmd = function()
            local ufo_loaded, ufo = pcall(require, 'ufo')
            if ufo_loaded then
                if ufo.peekFoldedLinesUnderCursor() then return end
            end
            return vim.diagnostic.open_float({ scope = 'cursor' }) or vim.lsp.buf.hover()
        end
    },
}

-- INFO: lsp_lines keymap
keymaps.lsp_lines = {
    toggle = '<leader>ll'
}

-- INFO: Treesitter
keymaps.treesitter = {
    incremental_selection = {
        init_selection = '<Tab>',
        node_incremental = '<Tab>',
        node_decremental = '<S-Tab>',
    },
}

-- INFO: Lazy keymap
keymaps.lazy = {
    open = '<leader>P',
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
}

-- INFO: GitSign keymap
keymaps.gitsigns = {
    next_hunk    = ']c',
    prev_hunk    = '[c',
    stage_hunk   = '<leader>hs',
    reset_hunk   = '<leader>hr',
    preview_hunk = '<leader>hp',
    blame_line   = '<leader>hb',
    toggle_blame = '<leader>hB',
    diff_this    = '<leader>hd',
}

-- INFO: git-conflict keymap
keymaps.gitconflict = {
    toggle_qflist = '<leader>x',
}

-- INFO: Telescope keymap
keymaps.telescope = {
    grep_workspace       = 'gw',
    search_buffer        = '<leader>/',
    search_workspace     = '<leader>fw',
    buffers              = '<leader>\\',
    find_files           = '<leader>fs',
    help                 = '<leader>;',
    jumplist             = '<leader>j',
    oldfiles             = '<leader>?',
    file_browse          = '<leader>fb',
    action_buffer_delete = { n = 'd', i = '<m-d>' },
}

-- INFO: Todocomments keymap
keymaps.todocomments = {
    toggle    = '<leader>c',
    next_todo = ']t',
    prev_todo = '[t',
}

-- INFO: Terminal & ToggleTerm keymap
keymaps.toggleterm = {
    toggle = '<leader>t',
    lazygit = '<leader>g',
    lazygit_file_history = '<leader>G',
}

-- INFO: Marks keymap
keymaps.marks = {
    next    = "'",
    prev    = '"',
    toggle  = "m'",
    preview = 'm"',
    clear   = 'md',
    list    = '<leader>m',
}

-- INFO: ufo keymap
keymaps.ufo = {
    open_all    = 'zR',
    open_except = 'zr',
    close_all   = 'zM',
    close_with  = 'zm',
}

-- INFO: hlslens keymap
keymaps.hlslens = {
    search_next = 'n',
    search_prev = 'N',
    word_next   = '*',
    word_prev   = '#',
    go_next     = 'g*',
    go_prev     = 'g#',
}

-- INFO: session-manager keymaps
keymaps.session_manager = {
    load   = '<leader>sr',
    save   = '<leader>ss',
    delete = '<leader>sd',
}

-- INFO: Noice keymaps
keymaps.noice = {
    history          = '<leader>M',
    docs_scroll_up   = '<C-u>',
    docs_scroll_down = '<C-d>',
}

-- INFO: flit keymaps
keymaps.flit = {
    forward  = 'f',
    backward = 'F',
    till     = 't',
    backtill = 'T',
    leap     = 's',
}

-- INFO: markdown preview keymap
keymaps.markdown_preview = {
    toggle = '<leader>p',
}

-- INFO: mini.bufremove keymap
keymaps.bufremove = {
    delete = 'wQ',
}

-- INFO: mini.move keymap
keymaps.move = {
    move_up    = '<m-k>',
    move_down  = '<m-j>',
    move_left  = '<m-h>',
    move_right = '<m-l>',
}

-- INFO: muren search-replace keymap
keymaps.muren = {
    toggle = '<leader>r',
    unique = '<leader>R',
}

-- INFO: treesj keymap
keymaps.treesj = {
    toggle = 'J',
}

return keymaps
