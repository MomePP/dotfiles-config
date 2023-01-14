local M = {
    'b0o/incline.nvim',
    event = 'BufReadPre'
}

M.config = function()
    require('incline').setup {
        window = {
            margin = {
                horizontal = 0,
                vertical = 0,
            },
            zindex = 10,
        },
        render = function(props)
            local bufname = vim.api.nvim_buf_get_name(props.buf)
            local render_path = bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'
            local render_modified = vim.api.nvim_buf_get_option(props.buf, 'modified') and '  ' or ' '

            return {
                { ' ', group = 'InclineSpacing' },
                { render_modified, group = 'InclineModified' },
                render_path
            }
        end,
    }
end

return M
