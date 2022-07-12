local status_ok, session_manager = pcall(require, 'session_manager')
if not status_ok then return end

session_manager.setup({
    autoload_mode = require('session_manager.config').AutoloadMode.CurrentDir,
    autosave_ignore_not_normal = true,
    autosave_only_in_session = true,
})
