local bufremove_keymap = require('keymaps').bufremove

return {
    'echasnovski/mini.bufremove',
    keys = {
        {
            bufremove_keymap.delete,
            function()
                require('mini.bufremove').delete(0, false)
            end,
            desc = 'Delete Buffer',
        },
        {
            bufremove_keymap.force_delete,
            function()
                require('mini.bufremove').delete(0, true)
            end,
            desc = 'Delete Buffer (Force)',
        },
    },
}
