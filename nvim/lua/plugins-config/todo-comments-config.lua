local status_ok, todocomments = pcall(require, 'todo-comments')
if not status_ok then return end

local todocomment_colors = require('colorscheme').colorset.todocomments

todocomments.setup {
    signs = true, -- show icons in the signs column
    sign_priority = 8, -- sign priority
    -- keywords recognized as todo comments
    keywords = {
        INFO = { icon = ' ', color = 'info' },
        TODO = { icon = ' ', color = 'todo' },
        HACK = { icon = ' ', color = 'hack' },
        WARN = { icon = ' ', color = 'warn', alt = { 'WARNING' } },
        NOTE = { icon = ' ', color = 'hint', alt = { 'HINT' } },
        PERF = { icon = ' ', color = 'perf', alt = { 'OPTIMIZE' } },
        FIX = { icon = ' ', color = 'error', alt = { 'ERROR', 'BUG', 'ISSUE' } },
    },
    merge_keywords = true, -- when true, custom keywords will be merged with the defaults
    -- highlighting of the line containing the todo comment
    -- * before: highlights before the keyword (typically comment characters)
    -- * keyword: highlights of the keyword
    -- * after: highlights after the keyword (todo text)
    highlight = {
        before = '', -- 'fg' or 'bg' or empty
        keyword = 'wide', -- 'fg', 'bg', 'wide' or empty. (wide is the same as bg, but will also highlight surrounding characters)
        after = 'fg', -- 'fg' or 'bg' or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 200, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
    },
    -- list of named colors where we try to extract the guifg from the
    -- list of hilight groups or use the hex color if hl not found as a fallback
    colors = todocomment_colors,
    search = {
        command = 'rg',
        args = {
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
        },
        -- regex that will be used to match keywords.
        -- don't replace the (KEYWORDS) placeholder
        pattern = [[\b(KEYWORDS):]], -- ripgrep regex
        -- pattern = [[\b(KEYWORDS)\b]], -- match without the extra colon. You'll likely get false positives
    },
}

local todocomments_keymap = require('keymappings').todocomments

vim.keymap.set('n', todocomments_keymap.toggle, '<Cmd>TodoTelescope<CR>', todocomments_keymap.opts)

vim.keymap.set('n', todocomments_keymap.next_todo,
    function()
        todocomments.jump_next()
    end, todocomments_keymap.opts)

vim.keymap.set('n', todocomments_keymap.prev_todo,
    function()
        todocomments.jump_prev()
    end, todocomments_keymap.opts)
