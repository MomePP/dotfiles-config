local M = {
    'b0o/incline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-web-devicons' },
}

M.opts = function()
    -- local helpers = require 'incline.helpers'

    return {
        debounce_threshold = {
            rising = 50,
            falling = 100
        },
        window = {
            padding = { left = 0, right = 1 },
            margin = { horizontal = 0, vertical = 1 },
            zindex = 10,
        },
        render = function(props)
            local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
            local ft_icon, ft_color = require('nvim-web-devicons').get_icon_color(filename)
            local buffer = {
                ' ',
                ft_icon and { ft_icon, guifg = ft_color } or '',
                ' ',
                { filename, gui = 'bold', guifg = vim.bo[props.buf].modified and '#ffaa00' or nil },
            }
            return buffer
        end,
    }
end

return M
