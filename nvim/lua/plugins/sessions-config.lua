local M = {
    'nvim-mini/mini.sessions',
    main = 'mini.sessions',
    lazy = false,
}

-- NOTE: one global session per directory, same name scheme resession used
local function cwd_session_name()
    return (vim.fn.getcwd():gsub('/', '_'):gsub(':', '_'))
end

M.config = function()
    local sessions = require('mini.sessions')

    sessions.setup {
        autoread = false, -- autoread only matches local/latest; cwd-keyed read below
        autowrite = true, -- persist on exit only when a session was read/written
        directory = vim.fn.stdpath('data') .. '/sessions',
        file = '',        -- disable local (Session.vim) sessions
    }

    -- NOTE: load the dir-specific session when opening nvim without file args
    vim.api.nvim_create_autocmd('VimEnter', {
        callback = function()
            local name = cwd_session_name()
            if vim.fn.argc(-1) == 0 and MiniSessions.detected[name] then
                sessions.read(name)
            end
        end,
        nested = true,
    })
end

M.keys = function()
    local session_keymap = require('config.keymaps').sessions

    return {
        { session_keymap.save,   function() require('mini.sessions').write(cwd_session_name()) end },
        { session_keymap.delete, function() require('mini.sessions').delete(cwd_session_name(), { force = true }) end },
    }
end

return M
