local M = {
    'folke/todo-comments.nvim',
    cmd = { 'TodoTelescope' },
    event = 'BufReadPost'
}

M.opts = {
    signs = false,
    keywords = {
        INFO = { icon = ' ', color = 'info' },
        TODO = { icon = ' ', color = 'todo' },
        HACK = { icon = ' ', color = 'hack' },
        WARN = { icon = ' ', color = 'warn', alt = { 'WARNING' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'HINT' } },
        PERF = { icon = ' ', color = 'perf', alt = { 'OPTIMIZE' } },
        FIX = { icon = ' ', color = 'error', alt = { 'ERROR', 'BUG', 'ISSUE' } },
    },
    merge_keywords = false, -- when true, custom keywords will be merged with the defaults
    highlight = {
        multiline = true, -- enable multine todo comments
        multiline_pattern = '^.', -- lua pattern to match the next multiline from the start of the matched keyword
        multiline_context = 10, -- extra lines that will be re-evaluated when changing a line
        before = '',
        keyword = 'wide_bg', -- 'fg', 'bg', 'wide', 'wide_bg', 'wide_fg' or empty. (wide and wide_bg is the same as bg, but will also highlight surrounding characters, wide_fg acts accordingly but with fg)
        after = 'fg', -- 'fg' or 'bg' or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 200, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
    },
    colors = require('plugins.colorscheme').colorset.todocomments,
    search = {
        command = 'rg',
        args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
        },
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
    },
}

M.config = function(_, opts)
    require('todo-comments').setup(opts)

    -- HACK: force keyword highlight from wide_bg to bold fg style
    for kw, options in pairs(opts.keywords) do
        vim.api.nvim_set_hl(0, 'TodoBg' .. kw, { fg = opts.colors[options.color], bg = 'NONE', bold = true })
    end
end

M.keys = function()
    -- INFO: setup todocomments keymap
    local todocomments = require('todo-comments')
    local todocomments_keymap = require('config.keymaps').todocomments

    return {
        { todocomments_keymap.toggle, '<Cmd>TodoTelescope<CR>' },
        { todocomments_keymap.next_todo, function() todocomments.jump_next() end },
        { todocomments_keymap.prev_todo, function() todocomments.jump_prev() end },
    }
end

return M
