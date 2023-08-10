local M = {
    'b0o/incline.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'nvim-web-devicons' },
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
            padding = { left = 0, right = 1 },
            margin = { horizontal = 0, vertical = 1 },
            zindex = 40,
        },
        render = function(props)
            local bufname = vim.api.nvim_buf_get_name(props.buf)

            local render_path = truncate_utils(
                (bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'),
                MAX_PATH_WIDTH,
                nil,
                -1
            )

            local render_icon = {}
            if vim.api.nvim_buf_get_option(props.buf, 'modified') then
                render_icon = { '  ', group = 'InclineModified' }
            else
                local icon, icon_hl = require('nvim-web-devicons').get_icon(
                    vim.fn.fnamemodify(bufname, ':t'),
                    vim.fn.fnamemodify(bufname, ':e'),
                    { default = true }
                )
                render_icon = { ' ', icon, ' ', group = icon_hl }
            end

            return {
                render_icon,
                render_path,
            }
        end,
    }
end

return M
