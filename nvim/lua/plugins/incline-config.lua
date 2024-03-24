local M = {
    'b0o/incline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = { 'nvim-web-devicons' },
}

M.opts = function()
    local truncate_utils = require('plenary.strings').truncate

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
            local bufname = vim.api.nvim_buf_get_name(props.buf)
            local win_width = vim.api.nvim_win_get_width(props.win)
            local line_number = vim.fn.line('w0', props.win) - 1
            local first_line_length = vim.api.nvim_buf_get_lines(props.buf, line_number, line_number + 1, false)[1]:len()
            local path_length = win_width - first_line_length - 10
            if not props.focused then
                local filename_length = vim.fn.fnamemodify(bufname, ":t"):len()
                path_length = math.max(path_length, filename_length + 2)
            end
            local icon, icon_hl = require('nvim-web-devicons').get_icon(
                vim.fn.fnamemodify(bufname, ':t'),
                vim.fn.fnamemodify(bufname, ':e'),
                { default = true }
            )

            local render_icon = { ' ', icon, ' ', group = icon_hl }
            local render_path = truncate_utils(
                (bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'),
                path_length,
                nil,
                -1
            )
            return {
                { render_icon },
                { render_path, gui = 'bold', guifg = vim.bo[props.buf].modified and '#ffaa00' or nil },
            }
        end,
    }
end

return M
