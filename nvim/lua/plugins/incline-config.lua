local M = {
    'b0o/incline.nvim',
    event = { 'BufReadPre', 'BufNewFile' }
}

M.opts = function()
    local truncate_utils = require('plenary.strings').truncate
    local MAX_PATH_WIDTH = 50

    return {
        debounce_threshold = {
            rising = 50,
            falling = 100
        },
        window = {
            margin = {
                horizontal = 0,
                vertical = 0,
            },
            zindex = 40,
        },
        render = function(props)
            local bufname = vim.api.nvim_buf_get_name(props.buf)
            local render_path = truncate_utils(
                (bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'),
                MAX_PATH_WIDTH,
                nil,
                -1)

            local render_modified = vim.api.nvim_buf_get_option(props.buf, 'modified') and '  ' or ' '

            return {
                { ' ',             group = 'InclineSpacing' },
                { render_modified, group = 'InclineModified' },
                render_path
            }
        end,
    }
end

return M
