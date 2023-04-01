local M = {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
}

M.opts = {
    panel = {
        keymap = {
            refresh = '<M-r>'
        },
        layout = {
            ratio = 0.33
        }
    },
    suggestion = {
        auto_trigger = true,
        keymap = {
            accept = false,
            dismiss = false,
        }
    },
}

return M
