local M = {
    'Shatur/neovim-session-manager',
    event = 'VimEnter'
}

M.keys = function()
    local session_manager = require('session_manager')
    local session_manager_keymaps = require('config.keymaps').session_manager

    return {
        { session_manager_keymaps.load, session_manager.load_session },
        { session_manager_keymaps.save, session_manager.save_current_session },
        { session_manager_keymaps.delete, session_manager.delete_session },
    }
end

M.setup = function()
    require('session_manager').setup {
        autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
        autosave_ignore_not_normal = true,
        autosave_only_in_session = true,
    }
end

return M
