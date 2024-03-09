local copilot = {
    'zbirenbaum/copilot.lua',
    event = 'InsertEnter',
    cmd = 'Copilot',
}

copilot.opts = function()
    local copilot_keymap = require('config.keymaps').copilot

    return {
        suggestion = {
            auto_trigger = false,
            keymap = {
                accept = false,
                dismiss = false,
                next = copilot_keymap.next,
                prev = copilot_keymap.prev,
            }
        },
        panel = { enabled = false },
    }
end

local copilot_lualine = {
    'AndreM222/copilot-lualine',
}

return {
    copilot,
    copilot_lualine,
}
