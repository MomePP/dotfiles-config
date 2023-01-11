local M = {
    'b0o/incline.nvim',
    event = 'BufReadPre'
}

M.config = function()
    local incline = require('incline')
    local colors = require('plugins.colorscheme').colorset

    incline.setup {
        window = {
            margin = {
                horizontal = 0,
                vertical = 0,
            },
            zindex = 10,
        },
        highlight = {
            groups = {
                InclineNormal = {
                    guifg = vim.o.background ~= 'dark' and colors.black or colors.white,
                    guibg = colors.transparent,
                    gui = 'bold'
                },
                InclineNormalNC = {
                    guifg = colors.gray,
                    guibg = colors.transparent,
                },
                InclineSpacing = {
                    guifg = colors.white,
                    guibg = colors.orange,
                },
                InclineModified = {
                    guifg = colors.red,
                    guibg = colors.transparent,
                }
            }
        },
        render = function(props)
            local bufname = vim.api.nvim_buf_get_name(props.buf)
            local render_path = bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'
            local render_modified = vim.api.nvim_buf_get_option(props.buf, 'modified') and '  ' or ' '
            -- local mode_color = colors.modes[(vim.api.nvim_get_mode().mode)]
            -- print(vim.inspect(mode_color))
            -- local icon, color = require('nvim-web-devicons').get_icon_color(vim.fn.fnamemodify((bufname), ':t'))
            -- local render_icon = icon .. ' '

            local render_incline = {}
            table.insert(render_incline, { ' ', group = 'InclineSpacing' })
            -- table.insert(render_incline, { ' ', guibg = mode_color })
            table.insert(render_incline, { render_modified, group = 'InclineModified' })
            -- table.insert(render_incline, { render_icon, guifg = color })
            table.insert(render_incline, render_path)
            return render_incline
        end,
    }
end

return M
