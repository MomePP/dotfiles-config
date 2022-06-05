local status_ok, incline = pcall(require, 'incline')
if not status_ok then return end

incline.setup {
    highlight = {
        groups = {
            InclineNormal = {
                guifg = '#e4e4e4',
                guibg = '#6100e0',
                gui = 'bold'
            },
            InclineNormalNC = {
                guifg = '#a8a8a8',
                -- guibg = '#2A2A37',
                guibg = 'NONE',
            }
        }
    },
    render = function(props)
		local bufname = vim.api.nvim_buf_get_name(props.buf)
        local res = bufname ~= '' and vim.fn.fnamemodify(bufname, ':.') or '[No Name]'
        if vim.api.nvim_buf_get_option(props.buf, 'modified') then
            res = ' ' .. res
        end
        return res
	end,
    window = {
        margin = {
            horizontal = 0,
            vertical = 0,
        }
    }
}

