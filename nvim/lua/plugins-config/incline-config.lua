local status_ok, incline = pcall(require, 'incline')
if not status_ok then return end

local colors = {
    purple = '#6100e0',
    red = '#ff3838',
    white = '#e4e4e4',
    gray = '#989898',
    orange = '#ff7800',
    transparent = 'NONE',
}

incline.setup {
    highlight = {
        groups = {
            InclineNormal = {
                guifg = colors.white,
                guibg = colors.transparent,
                gui = 'bold'
            },
            InclineNormalNC = {
                guifg = colors.gray,
                guibg = colors.transparent,
            },
            InclineSpacing = {
                guifg = colors.white,
                guibg = colors.purple,
                -- guibg = colors.orange,
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

        local render_incline = {}
        table.insert(render_incline, { ' ', group = 'InclineSpacing' })
        table.insert(render_incline, { render_modified, group = 'InclineModified' })
        table.insert(render_incline, render_path)
        return render_incline
    end,
    window = {
        margin = {
            horizontal = 0,
            vertical = 0,
        }
    }
}

-- PERF: remove some of events triggered by incline that not being used in my config
-- vim.api.nvim_clear_autocmds({
--     group = 'incline',
--     event = { 'CursorMoved', 'CursorMovedI', 'CursorHold', 'CursorHoldI' }
-- })
