local M =    {
    'roobert/search-replace.nvim',
}

M.opts = {
    default_replace_single_buffer_options = 'gcI',
    default_replace_multi_buffer_options = 'egcI',
}

M.keys = function ()
    local search_replace_keymap = require('config.keymaps').search_replace

    return {
        { search_replace_keymap.single_open, '<Cmd>SearchReplaceSingleBufferCWord<CR>' },
        { search_replace_keymap.multi_open, '<Cmd>SearchReplaceMultiBufferCWord<CR>' },
    }
end

return M
