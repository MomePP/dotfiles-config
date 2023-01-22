local M = {
    'Shatur/neovim-session-manager',
    event = 'VimEnter'
}

M.opts = function()
    return {
        autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
        autosave_ignore_not_normal = true,
        autosave_only_in_session = true,
    }
end

M.keys = function()
    local session_manager_keymaps = require('config.keymaps').session_manager

    return {
        { session_manager_keymaps.load, function() require('session_manager').load_session() end },
        { session_manager_keymaps.save, function() require('session_manager').save_current_session() end },
        { session_manager_keymaps.delete, function() require('session_manager').delete_session() end },
    }
end

return M
